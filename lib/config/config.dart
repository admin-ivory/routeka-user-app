

class config {
  // Step 1: Singleton instance
  static final config _instance = config._internal();

  // Step 2: Factory constructor returns the same instance
  factory config() {
    return _instance;
  }

  // Step 3: Private constructor
  config._internal();

  // Config fields
  String baseUrl = "https://routeka.afroo-app.com";
  String oneSignel = "c62afa1c-2d39-47a3-8c53-5b2c098e96d0";
  String msgapi = "/api/msg_otp.php";
  String twilioapi = "/api/twilio_otp.php";
  String smstypeapi = "/api/sms_type.php";
  String mapkey = "";


  String initialCountryCode = "IN";


}
