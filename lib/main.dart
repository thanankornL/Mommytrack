import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:carebellmom/adminPages/admin.dart';
import 'package:carebellmom/nursePages/nurse.dart';
import 'package:carebellmom/patientPages/patient.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness:
          Brightness
              .light, // For dark icons (use Brightness.light for white icons)
    ),
  );
  await dotenv.load(fileName: '.env');
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xffffffff),

        // Main colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
            255,
            255,
            88,
            130,
          ), // Your primary color
          brightness: Brightness.light,
        ),

        // AppBar styling
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 255, 88, 130),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // Button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 88, 130), // Primary
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: IntroPage(),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
       
        child: Column(
          children: [
            SizedBox(height: 50),
    

            Image.asset(
              'assets/intro_page/pic5.png',
              height: screenHeight * 0.5, // 30% of the screen height
              width: screenWidth * 0.6, // 50% of the screen width
              fit: BoxFit.contain, // Ensures the image scales proportionally
            ), // ภาพพยาบาล

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Carebellmom ',
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: screenHeight * 0.04,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 5, 5, 5),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Text(
                'Every day, a pregnant woman is not just waiting to give birth to a baby, but she is still a child discovering the miracle of life inside a body that is as wonderful as a fairyland, where every movement is a whisper of hope and eternal love.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 136, 136, 136),
                ),
              ),
            ),

            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.06,
                  left: screenWidth * 0.75,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConsentPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          screenWidth * 0.06,
                          screenHeight * 0.10,
                        ),
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // มุมมน
                        ),
                        shadowColor: Colors.grey,
                      ),
                      child: Icon(
                        Icons.arrow_right_alt_sharp,
                        size: screenHeight * 0.03,
                        color: const Color.fromARGB(255, 21, 150, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "ขอสิทธิ์ในการเข้าถึงข้อมูลส่วนตัว",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontFamily: "Inter",
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: screenWidth * 1,
              height: screenHeight * 0.5,
            ),

            Text(
              "เราอาจมีการเก็บข้อมูลส่วนบุคคลของคุณ เช่น ชื่อ อายุ วันคลอด และข้อมูลสุขภาพ เพื่อใช้ในการให้บริการดูแลสุขภาพที่เหมาะสมกับคุณ ข้อมูลจะถูกเก็บรักษาอย่างปลอดภัยตามมาตรฐานความเป็นส่วนตัว",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                  activeColor: Colors.pink,
                ),
                Expanded(
                  child: Text(
                    "ข้าพเจ้ายินยอมให้แอปเก็บรวบรวมและใช้ข้อมูลของข้าพเจ้า",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0,
                  left: screenWidth * 0.5,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed:
                          isChecked
                              ? () {
                                // ดำเนินการต่อเมื่อยินยอม
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginForm(),
                                  ),
                                ); // หรือไปหน้าถัดไป
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          screenWidth * 0.08,
                          screenHeight * 0.10,
                        ), // ความกว้าง x ความสูง
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ), // สีพื้นหลังปุ่ม
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // มุมมน
                        ),
                        shadowColor: Colors.grey,
                      ),
                      child: Icon(
                        Icons.arrow_right_alt_sharp,
                        size: 40,
                        color: const Color.fromARGB(255, 21, 150, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both username and password"),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('role', data['role']);
        await prefs.setString('name', data['name']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful! Welcome ${data['name']}")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        /*
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color.fromARGB(255, 249, 184, 255), Colors.white],
          ),
        ),*/
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 20,
              left: 10.0,
              child: Image.asset("assets/intro_page/pic0.png", height: 40),
            ),

            Positioned(
              top: 59,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset("assets/login_page/pic2.png", height: 250),
              ),
            ),

            Positioned(
              top: 250,
              left: 40,
              right: 40,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: screenWidth * 0.095,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),

                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTap: _togglePasswordVisibility,
                          child: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _showPassword,
                          onChanged: (bool? value) {
                            _togglePasswordVisibility();
                          },
                        ),
                        Text("Show Password"),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Color.fromARGB(255, 255, 88, 130),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 1,
  );
  final int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: SharedPreferences.getInstance().then(
          (prefs) => prefs.getString('role') ?? 'user',
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return getWidgetByRole(snapshot.data ?? 'user');
          }
        },
      ),
    );
  }
}

Widget getWidgetByRole(String role) {
  switch (role) {
    case 'nurse':
      return NursePage();
    case 'admin':
      return AdminPage();
    case 'patient':
    default:
      return PatientPage();
  }
}
