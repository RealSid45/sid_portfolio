/**
 * Firebase Functions V2
 * Portfolio Contact Form Email Function
 */

const functions = require("firebase-functions");
const {setGlobalOptions} = require("firebase-functions/v2");
const {onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");

// Set global options for cost control
setGlobalOptions({ maxInstances: 10 });

// ============================================
// EMAIL CONFIGURATION
// ============================================

// IMPORTANT: Set these using Firebase CLI before deploying
// firebase functions:config:set gmail.email="sidhuxplore4@gmail.com"
// firebase functions:config:set gmail.password="keas lkvs nmtv lvns"
const EMAIL_USER = functions.config().gmail.email;
const EMAIL_PASS = functions.config().gmail.password;

// Create email transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: EMAIL_USER,
    pass: EMAIL_PASS,
  },
});

// ============================================
// PORTFOLIO CONTACT FORM FUNCTION
// ============================================

exports.sendPortfolioContactEmail = onCall(async (request) => {
  // Get data from request
  const {name, email, message} = request.data;

  // Validate input
  if (!name || !email || !message) {
    logger.error("Missing required fields", {name, email, message});
    throw new Error("Missing required fields: name, email, or message");
  }

  // Validate email format
  const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
  if (!emailRegex.test(email)) {
    logger.error("Invalid email format", {email});
    throw new Error("Invalid email address format");
  }

  logger.info("Processing contact form submission", {
    name,
    email,
    messageLength: message.length,
  });

  // Email content
  const mailOptions = {
    from: EMAIL_USER,
    to: EMAIL_USER, // Send to yourself
    replyTo: email, // Allow replying to sender
    subject: `🎯 Portfolio Contact from ${name}`,
    html: `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body {
              font-family: Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              margin: 0;
              padding: 0;
            }
            .container {
              max-width: 600px;
              margin: 0 auto;
              padding: 20px;
            }
            .header {
              background: linear-gradient(135deg, #F86E5B, #924136);
              padding: 30px;
              text-align: center;
              border-radius: 10px 10px 0 0;
            }
            .header h1 {
              color: white;
              margin: 0;
              font-size: 24px;
            }
            .content {
              background: #f9f9f9;
              padding: 30px;
              border-radius: 0 0 10px 10px;
            }
            .field {
              margin-bottom: 20px;
            }
            .field label {
              font-weight: bold;
              color: #F86E5B;
              display: block;
              margin-bottom: 5px;
            }
            .field p {
              margin: 0;
              padding: 10px;
              background: white;
              border-left: 3px solid #F86E5B;
              word-wrap: break-word;
            }
            .footer {
              text-align: center;
              margin-top: 20px;
              color: #999;
              font-size: 12px;
            }
            a {
              color: #F86E5B;
              text-decoration: none;
            }
            a:hover {
              text-decoration: underline;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>📬 New Portfolio Contact</h1>
            </div>
            <div class="content">
              <div class="field">
                <label>👤 Name:</label>
                <p>${name}</p>
              </div>
              <div class="field">
                <label>📧 Email:</label>
                <p><a href="mailto:${email}">${email}</a></p>
              </div>
              <div class="field">
                <label>💬 Message:</label>
                <p>${message.replace(/\n/g, "<br>")}</p>
              </div>
            </div>
            <div class="footer">
              <p>Sent from Portfolio Contact Form</p>
              <p>${new Date().toLocaleString("en-US", {
                timeZone: "Asia/Kolkata",
                dateStyle: "full",
                timeStyle: "short",
              })}</p>
            </div>
          </div>
        </body>
      </html>
    `,
    text: `
Portfolio Contact Form Submission

Name: ${name}
Email: ${email}

Message:
${message}

---
Sent: ${new Date().toLocaleString()}
    `,
  };

  try {
    // Send email
    const info = await transporter.sendMail(mailOptions);

    logger.info("Email sent successfully", {
      messageId: info.messageId,
      name,
      email,
    });

    return {
      success: true,
      message: "Email sent successfully",
      messageId: info.messageId,
    };
  } catch (error) {
    logger.error("Error sending email", {
      error: error.message,
      stack: error.stack,
      name,
      email,
    });

    throw new Error(`Failed to send email: ${error.message}`);
  }
});

// ============================================
// EXAMPLE: Hello World Function (Optional - Remove if not needed)
// ============================================

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
