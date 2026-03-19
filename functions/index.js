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
  .onCreate(async (snap) => {
    const data = snap.data();
    const departmentEmail = getDepartmentEmail(data.category);

    const mailOptions = {
      from: `"SpotIt" <${GMAIL_EMAIL.value()}>`,
      to: departmentEmail,
      subject: `🚨 New Civic Issue: ${data.category}`,
      html: `
        <h2>New Civic Issue Reported</h2>
        <p><strong>Category:</strong> ${data.category}</p>
        <p><strong>Description:</strong> ${data.description}</p>
        <p><strong>Location:</strong> ${data.location}</p>
        <p><strong>Status:</strong> Pending</p>
        <hr/>
        <p>Reported via <strong>SpotIt App</strong></p>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log("✅ Email sent to:", departmentEmail);
    } catch (error) {
      console.error("❌ Email failed:", error);
    }
  });
