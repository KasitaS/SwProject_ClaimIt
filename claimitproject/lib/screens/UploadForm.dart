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
  List<String> selectedColors = []; // List to hold selected colors
  String description = '';
  bool isLoading = false;
  File? _selectedImage;

  final List<String> colors = [
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Black',
    'White',
    'Purple',
    'Orange'
  ];

  final _conName = TextEditingController();
  final _conLocation = TextEditingController();
  final _conDescription = TextEditingController();

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
                          onPressed: _pickImageFromGallery,
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
                          onPressed: _openCamera,
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
                    Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: colors.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedColors.contains(colors[index])) {
                                  selectedColors.remove(colors[index]);
                                } else {
                                  selectedColors.add(colors[index]);
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: selectedColors.contains(colors[index])
                                    ? Colors.grey[300]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  colors[index],
                                  style: TextStyle(
                                    color:
                                        selectedColors.contains(colors[index])
                                            ? Colors.black
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                          onPressed: _uploadItem,
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
            .getDetected(pickedFile.path); 
        String cleanedDetectedObject = detectedObject.substring(1);

        cleanedDetectedObject = cleanedDetectedObject.substring(
            1, cleanedDetectedObject.length - 2);

        print('Detected Object: $cleanedDetectedObject');
        _conName.text = cleanedDetectedObject; 
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
            .getDetected(pickedFile.path); 

        String cleanedDetectedObject = detectedObject.substring(1);

        cleanedDetectedObject = cleanedDetectedObject.substring(
            1, cleanedDetectedObject.length - 2);

        print('Detected Object: $cleanedDetectedObject');
        _conName.text = cleanedDetectedObject; 
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
          await getApplicationDocumentsDirectory();
      String uniqueFilename =
          'image_${DateTime.now().millisecondsSinceEpoch}.png'; 
      final filePath =
          '${directory.path}/$uniqueFilename'; 

      File file = File(filePath);
      await file.writeAsBytes(imageBytes); 

      return filePath; 
    } catch (e) {
      print("Error saving image: $e");
      return '';
    }
  }

  // Upload part starts
  Future<void> _uploadItem() async {
    if (_selectedImage == null ||
        selectedCategory == null ||
        selectedLocation == null ||
        _conName.text.isEmpty ||
        _conDescription.text.isEmpty ||
        selectedColors.isEmpty) {
      return;
    }
    setState(() {
      isLoading = true; 
    });

    String itemType = widget.itemPoster.runtimeType == User ? 'Lost' : 'Found';
    Uint8List bgRemovedImage =
        await APIService.instance.remove_bg(_selectedImage!.path);
    String nobgImagePath =
        await _saveImageLocally(bgRemovedImage); 

    Item item = Item(
      name: _conName.text,
      category: selectedCategory ?? 'Unknown',
      location: selectedLocation ?? 'Unknown',
      color: selectedColors.join(', '), 
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
        isLoading = false; 
      });
    } catch (e) {
      print('Error uploading item: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (widget.itemPoster is User) {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text(
                'Please check the recommendation page to see the similar item, if any.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to the previous page
                },
                child: Text('OK'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text('Your item has been successfully uploaded.'),
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
        }
      },
    );
  }
}
