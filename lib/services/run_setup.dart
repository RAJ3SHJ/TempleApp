import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'setup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await SetupService.createSuperAdmin(
    email: 'rajeshjyothi1230@gmail.com',
    password: '9989034',
  );
  
  print('Done!');
}
