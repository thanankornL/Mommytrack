// index.js
const express = require("express");
const cors = require("cors");
const { MongoClient } = require("mongodb");
const bcrypt = require("bcrypt");
const cron = require("node-cron");
const { exec } = require("child_process");
const { runDailyCheck } = require("./dailyTrimesterCheck");
const { runDailyGACheck } = require("./updateGA");
const app = express();
const port = process.env.PORT || 3000;




// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
const uri = "mongodb+srv://thanankornc2551:25082551@carebellmom.lpfhwhk.mongodb.net"; 
const client = new MongoClient(uri);

let db; 

// Connect to MongoDB
async function connectToDatabase() {
  try {
    await client.connect();
    db = client.db("User"); 
    console.log("Connected to MongoDB");

    // Log all collections in the database
    const collections = await db.listCollections().toArray();
    console.log("Collections in the database:", collections.map((col) => col.name));
  } catch (err) {
    console.error("MongoDB connection error:", err);
    process.exit(1); 
  }
}
connectToDatabase();

cron.schedule("* * * * *", async () => {
  console.log("⏰ Running Daily Trimester and GA Check...");

  try {
    // Run both tasks sequentially
    await runDailyGACheck();
    await runDailyCheck();
  } catch (error) {
    console.error("❌ Error during scheduled task:", error);
  }
});


// Simple route
app.get("/", (req, res) => {
  res.send("Backend is working!");
});
// Example API route
app.post("/api/echo", (req, res) => {
  const { message } = req.body;
  res.json({ received: message });
});

// Login API route
app.post("/api/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    // Check if user exists in the database
    const user = await db.collection("login_data").findOne({ username });
    if (user && await bcrypt.compare(password, user.password)) {
      res.json({
        success: true,
        message: "Login successful!",
        name: user.username,
        role: user.role,
      });
      console.log(user.role);
    } else {
      res.status(401).json({ success: false, message: "Invalid username or password" });
    }
  } catch (err) {
    console.error("Error during login:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post("/api/register", async (req, res) => {
  const { username, password, name, role, EDC = "", GA = "", LMP = "", US = "", telephone = "" } = req.body;
  try {
    const existingUser = await db.collection("login_data").findOne({ username });
    if (existingUser) {
      return res.status(409).json({ success: false, message: "Username already exists" });
    }
    console.log("Registering user:", { username, password, name, role, EDC, GA, LMP, US, telephone });
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert into login_data
    await db.collection("login_data").insertOne({
      username,
      password: hashedPassword,
      role,
    });

    // Insert into the appropriate collection
    if (role === "patient") {
      await db.collection("patients_data").insertOne({
        username,
        display_name: name,
        EDC,
        GA,
        LMP,
        US,
        telephone
      });
    } else if (role === "nurse") {
      await db.collection("nurses_data").insertOne({
        username,
        display_name: name,
        role,
        telephone, 
      });
    } else if (role == "admin") {
      await db.collection("admin_data").insertOne({
        username,
        display_name: name,
        role,
      });
    }

    res.status(201).json({ success: true, message: "User registered successfully" });
  } catch (err) {
    console.error("Error during registration:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post("/api/send_notification", async (req, res) => {
  const { username, title, body, timestamp } = req.body;
  console.log("Received notification data:", { username, title, body, timestamp });
  try {
    // Insert the message into the messages collection
    await db.collection("notifications_data").insertOne({ username, title, body, timestamp });
    res.status(201).json({ success: true, message: "Message sent successfully" });
  } catch (err) {
    console.error("Error sending message:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Get all users
app.get("/api/users", async (_, res) => {
  try {
    const users = await db.collection("patients_data").find({}, {
      projection: { username: 1, display_name: 1, telephone: 1 }
    }).toArray();
    
    console.log("Fetched users:", users); 
    res.json(users);
  } catch (err) {
    console.error("Error fetching users:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post("/api/get_user_data", async (req, res) => {
  const { username, role } = req.body;
  try {
    let collectionName;
    if (role === "patient") {
      collectionName = "patients_data";
    } else if (role === "nurse") {
      collectionName = "nurses_data";
    } else if (role === "admin") {
      collectionName = "admin_data";
    } else {
      return res.status(400).json({ success: false, message: "Invalid role" });
    }

    const userData = await db.collection(collectionName).findOne(
      { username },
      { projection: 
        { 
          _id: 0, 
          password: 0, 
          role: 0,
        } 
      } 
    );
    if (!userData) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.json(userData);
  } catch (err) {
    console.error("Error fetching user data:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});


app.post("/api/edit_user_data", async (req, res) => {
  const { username, role, data } = req.body;
  try {
    let collectionName;
    if (role === "patient") {
      collectionName = "patients_data";
    } else if (role === "nurse") {
      collectionName = "nurses_data";
    } else if (role === "admin") {
      collectionName = "admin_data";
    } else {
      return res.status(400).json({ success: false, message: "Invalid role" });
    }

    // Update the user data in the appropriate collection
    const result = await db.collection(collectionName).updateOne(
      { username },
      { $set: data }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ success: false, message: "User not found or no changes made" });
    }
    res.json({ success: true, message: "User data updated successfully" });
  } catch (err) {
    console.error("Error updating user data:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});
app.post("/api/delete_user", async (req, res) => {
  const { username, role } = req.body;
  try {
    let collectionName;
    if (role === "patient") {
      collectionName = "patients_data";
    } else if (role === "nurse") {
      collectionName = "nurses_data";
    } else if (role === "admin") {
      collectionName = "admin_data";
    } else {
      return res.status(400).json({ success: false, message: "Invalid role" });
    }

    // Delete the user from the appropriate collection
    const result = await db.collection(collectionName).deleteOne({ username });
    if (result.deletedCount === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.json({ success: true, message: "User deleted successfully" });
  } catch (err) {
    console.error("Error deleting user:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post("/api/get_GA_state", async (req, res) => {
  const { GA } = req.body;
  try {
    const state = getGATrimester(GA);
    console.log(GA);
    res.json({ success: true, state });
  } catch (err) {
    console.error("Error fetching GA state:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.get("/api/notifications", async (req, res) => {
  const { username } = req.query;
  console.log("Fetching notifications for user:", username);
  try {
    const messages = await db.collection("notifications_data").find(
      {
        username: username
      },
      {
        projection: { _id: 0 }
      }
    )
      .sort({ timestamp: -1 }) 
      .limit(10) 
      .toArray(); 

    console.log("Fetched notifications:", messages); 
    res.json(messages);
  } catch (err) {
    console.error("Error fetching messages:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.get('/api/getAction', async (req, res) => {
  const { username } = req.query;

  try {
    const patient = await db.collection("patients_data").findOne({ username });

    if (!patient) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.json({ success: true, action: patient.action });
  } catch (err) {
    console.error("Error fetching action:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post('/api/updateAction', async (req, res) => {
  const { username, action } = req.body;

  try {
    const updateResult = await db.collection("patients_data").updateOne(
      { username },
      { $set: { action } }
    );
    const addedChildDate = await db.collection("patients_data").updateOne(
      { username },
      { $set: { childDate: new Date() } }
    );
    if (updateResult.modifiedCount === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      message: "อัพเดทข้อมูลเสร็จสิ้น",
      action 
    });
  } catch (err) {
    console.error("Error updating action:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post('/api/create_baby_data', async (req, res) => {
  const { mother, birthday, action, gender, child} = req.body;

  try {
    const result = await db.collection("baby_data").insertOne({
      child : child,
      mother : mother,
      birthday : birthday,
      action : action,
      gender : gender,
    });

    if (result.insertedCount === 0) {
      return res.status(500).json({ success: false, message: "Failed to create baby data" });
    }

    res.status(201).json({ success: true, message: "Baby data created successfully" });
  } catch (err) {
    console.error("Error creating baby data:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post('/api/get_baby_data', async (req, res) => {
  const { mother } = req.body; // Get 'mother' from the request body
  console.log("Fetching baby data for mother:", mother); // Debugging log
  try {
    // Fetch baby data from the database using 'mother' as a filter
    const babyData = await db.collection("baby_data").findOne({ mother });

    if (!babyData) {
      // Respond with a 404 status if no data is found
      return res.status(404).json({ success: false, message: "Baby data not found" });
    }

    // Return the fetched baby data if found
    res.json({ success: true, data: babyData });
  } catch (err) {
    // Handle any errors and respond with a 500 status code
    console.error("Error fetching baby data:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
