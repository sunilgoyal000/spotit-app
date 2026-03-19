const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const { defineString } = require("firebase-functions/params");

admin.initializeApp();

/**
 * 🔐 Secure environment parameters
 * These replace functions.config()
 */
const GMAIL_EMAIL = defineString("GMAIL_EMAIL");
const GMAIL_PASSWORD = defineString("GMAIL_PASSWORD");

/**
 * 📧 Email transporter
 */
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: GMAIL_EMAIL.value(),
    pass: GMAIL_PASSWORD.value(),
  },
});

/**
 * 🏢 Department email mapping
 */
function getDepartmentEmail(category) {
  switch (category) {
    case "Garbage":
      return "mcd@city.gov";
    case "Water Leakage":
      return "waterdept@city.gov";
    case "Streetlight":
      return "pspcl@punjab.gov";
    case "Pothole":
      return "pwd@city.gov";
    default:
      return "admin@spotit.app";
  }
}

/**
 * 🚀 Firestore trigger → Send email
 */
exports.sendReportEmail = functions.firestore
  .document("reports/{reportId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // Rate limit: 5 reports/hour per user
    const now = admin.firestore.Timestamp.now();
    const oneHourAgo = new admin.firestore.Timestamp(
      now.seconds - 3600, 
      now.nanoseconds
    );
    const recentReports = await admin.firestore()
      .collection('reports')
      .where('userId', '==', data.userId)
      .where('createdAt', '>', oneHourAgo)
      .get();
    
    if (recentReports.size >= 5) {
      console.log('Rate limited user:', data.userId);
      return;
    }
    
    // Department email (add district support)
    const departmentEmail = getDepartmentEmail(data.category, data.district || 'Default');
    
    let attachment = null;
    if (data.imageUrl) {
      try {
        const bucket = admin.storage().bucket();
        const fileName = data.imageUrl.split('/').pop();
        const [file] = await bucket.file(`reports/${fileName}`).download();
        attachment = {
          filename: 'issue-photo.jpg',
          content: file,
          contentType: 'image/jpeg'
        };
      } catch (err) {
        console.error('Attachment download failed:', err);
      }
    }
    
    const mailOptions = {
      from: `"SpotIt" <${GMAIL_EMAIL.value()}>`,
      to: departmentEmail,
      cc: 'admin@spotit.app',
      subject: `🚨 [${data.district || 'City'}] ${data.category}: ${data.location.substring(0,50)}`,
      html: `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
<style>body{font-family:Arial;padding:20px;} .header{background:#ff4444;color:white;padding:20px;border-radius:8px;} table{border-collapse:collapse;width:100%;} th,td{border:1px solid #ddd;padding:12px;} .urgent{background:#ffeb3b;}</style>
</head>
<body>
<div class="header">
  <h1>🚨 New Civic Issue #${context.params.reportId.slice(-6)}</h1>
</div>
<table>
  <tr><th>Category</th><td>${data.category}</td></tr>
  <tr><th>Location</th><td>${data.location}</td></tr>
  ${data.lat ? `<tr><th>GPS</th><td>${data.lat}, ${data.lng}</td></tr>` : ''}
  <tr><th>District</th><td>${data.district || 'N/A'}</td></tr>
  <tr><th>Reporter</th><td>${data.name}${data.phone ? ' (' + data.phone + ')' : ''}</td></tr>
  <tr><th>Description</th><td>${data.description}</td></tr>
  ${data.imageUrl ? '<tr><th>Photo</th><td>(Attached)</td></tr>' : ''}
</table>
<p><strong>Action Required:</strong> Update status in <a href="https://spotit-admin.web.app/reports/${context.params.reportId}">SpotIt Admin</a></p>
<p>Reported via SpotIt App | <em>${new Date().toLocaleString()}</em></p>
</body>
</html>      
      `,
      attachments: attachment ? [attachment] : []
    };
    
    // Retry logic
    const maxRetries = 3;
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Email sent (attempt ${attempt}) to:`, departmentEmail);
        break;
      } catch (error) {
        console.error(`❌ Email attempt ${attempt} failed:`, error.message);
        if (attempt < maxRetries) {
          await new Promise(resolve => setTimeout(resolve, 2000 * attempt));
        }
      }
    }
  });
