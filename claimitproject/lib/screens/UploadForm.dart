import 'dart:io';

import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/ObjDetection_API.dart';
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/ui_helper/genTextFormField.dart';
import 'package:claimitproject/ui_helper/getDropDown.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
//import 'package:uuid/uuid.dart';

class UploadForm extends StatefulWidget {
  final ItemPoster itemPoster;
  UploadForm({Key? key, required this.itemPoster}) : super(key: key);

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  String? selectedCategory;
  String? selectedLocation;
  String name = '';
  String color = '';
  String description = '';
  bool isLoading = false;

  final _conName = TextEditingController();
  final _conColor = TextEditingController();
  final _conLocation = TextEditingController();
  final _conCategory = TextEditingController();
  final _conDescription = TextEditingController();

  File? _selectedImage;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Form'),
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
      ),
      body: isLoading // Show loading indicator if uploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      height: 200,
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                "Please select an image",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _pickImageFromGallery();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 57, 41, 21),
                          ),
                          child: Text(
                            'Pick Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            _openCamera();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 57, 41, 21)),
                          child: Text(
                            'Open Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(width: 8),
                    GetTextFormField(
                      controller: _conColor,
                      hintName: 'Color',
                      icon: Icons.palette,
                    ),
                    SizedBox(height: 16),
                    GetTextFormField(
                      controller: _conName,
                      hintName: 'Name',
                      icon: Icons.title,
                    ),
                    SizedBox(height: 8),
                    getDropdownFormField(
                      hintName: 'Category',
                      items: [
                        'IT Gadget',
                        'Stationary',
                        'Personal Belonging',
                        'Bag',
                        'Others'
                      ],
                      icon: Icons.category,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      value: selectedCategory,
                    ),
                    SizedBox(height: 8),
                    getDropdownFormField(
                      hintName: 'Location',
                      items: [
                        'HM Building',
                        'ECC Building',
                        'Engineering Faculty',
                        'Architect Faculty',
                        'Science Faculty',
                        'Business Faculty',
                        'Art Faculty',
                        'Others'
                      ],
                      icon: Icons.location_on,
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      value: selectedLocation,
                    ),
                    SizedBox(height: 8),
                    GetTextFormField(
                      controller: _conDescription,
                      hintName: 'Description',
                      icon: Icons.description,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _uploadItem();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 57, 41, 21),
                          ),
                          child: Text(
                            'Upload',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        String detectedObject = await APIService.instance
            .getDetected(pickedFile.path); // Pass the file path
        String cleanedDetectedObject = detectedObject.substring(1);

        // Remove the last two characters
        cleanedDetectedObject = cleanedDetectedObject.substring(
            1, cleanedDetectedObject.length - 2);

        print('Detected Object: $cleanedDetectedObject');
        _conName.text = cleanedDetectedObject; // Update name field
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _openCamera() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        String detectedObject = await APIService.instance
            .getDetected(pickedFile.path); // Pass the file path

        String cleanedDetectedObject = detectedObject.substring(1);

        // Remove the last two characters
        cleanedDetectedObject = cleanedDetectedObject.substring(
            1, cleanedDetectedObject.length - 2);

        print('Detected Object: $cleanedDetectedObject');
        _conName.text = cleanedDetectedObject; // Update name field
      } else {
        print('No image selected from camera.');
      }
    } catch (e) {
      print('Error opening camera: $e');
    }
  }

  Future<String> _saveImageLocally(Uint8List imageBytes) async {
    try {
      final directory =
          await getApplicationDocumentsDirectory(); // Get app's storage directory
      String uniqueFilename =
          'image_${DateTime.now().millisecondsSinceEpoch}.png'; // Generate unique filename
      final filePath =
          '${directory.path}/$uniqueFilename'; // Construct full file path

      File file = File(filePath);
      await file.writeAsBytes(imageBytes); // Write bytes to file

      return filePath; // Return saved file path
    } catch (e) {
      print("Error saving image: $e");
      return ''; // Return empty string in case of error
    }
  }

  //upload part starts
  Future<void> _uploadItem() async {
    if (_selectedImage == null ||
        selectedCategory == null ||
        selectedLocation == null ||
        _conName.text.isEmpty ||
        _conDescription.text.isEmpty ||
        _conColor.text.isEmpty) {
      // Display an error message or alert the user about missing information
      return;
    }
    setState(() {
      isLoading = true; // Start loading
    });

    String itemType = widget.itemPoster.runtimeType == User ? 'Lost' : 'Found';
    Uint8List bgRemovedImage =
        await APIService.instance.remove_bg(_selectedImage!.path);
    String nobgImagePath =
        await _saveImageLocally(bgRemovedImage); // No filename needed

    Item item = Item(
      name: _conName.text,
      category: selectedCategory ??
          'Unknown', // Joining selected colors into a string
      location: selectedLocation ?? 'Unknown',
      color: _conColor.text,
      description: _conDescription.text,
      image_path: _selectedImage!.path,
      itemType: itemType,
      nobg_image_path: nobgImagePath,
    );

    try {
      await widget.itemPoster.post(item);
      _showSuccessDialog();
      print('Item uploaded successfully');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    } catch (e) {
      print('Error uploading item: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text('Your item has been successfully uploaded'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }
}
