import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const editproductscreen = '/editproductscreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var isLoading = false;
  final _imageUrlcontroller = TextEditingController();
  final _imagefocus = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedproduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var isInit = true;

  var _initvalue = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };

  Future<void> _formsave() async {
    var isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      isLoading = true;
    });
    if (_editedproduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .update(_editedproduct.id, _editedproduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false).add(_editedproduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text('Something went wrong'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Ok'))
                  ],
                ));
      }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _imagefocus.addListener(() {
      updateImageUrl();
    });
  }

  @override
  void didChangeDependencies() {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == bool) {
      isInit = false;
    } else {
      isInit = true;
    }
    if (isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != '') {
        _editedproduct = Provider.of<Products>(context).findbyid(productId);
        _initvalue = {
          'title': _editedproduct.title,
          'price': _editedproduct.price.toString(),
          'description': _editedproduct.description,
          'imageUrl': '',
        };
        _imageUrlcontroller.text = _editedproduct.imageUrl;
      }
    }

    isInit = false;

    super.didChangeDependencies();
  }

  void updateImageUrl() {
    if (!_imagefocus.hasFocus) {
      if ((!_imageUrlcontroller.text.startsWith('http') &&
              !_imageUrlcontroller.text.startsWith('https')) ||
          (!_imageUrlcontroller.text.endsWith('png') &&
              !_imageUrlcontroller.text.endsWith('jpg') &&
              !_imageUrlcontroller.text.endsWith('jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlcontroller.dispose();
    _imagefocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _formsave, icon: Icon(Icons.save))],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initvalue['title'],
                          decoration: InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _editedproduct = Product(
                                id: _editedproduct.id,
                                title: value as String,
                                description: _editedproduct.description,
                                price: _editedproduct.price,
                                imageUrl: _editedproduct.imageUrl,
                                isFavourite: _editedproduct.isFavourite);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter value';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initvalue['price'],
                          decoration: InputDecoration(
                            labelText: 'Price',
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            _editedproduct = Product(
                                id: _editedproduct.id,
                                title: _editedproduct.title,
                                description: _editedproduct.description,
                                price: double.parse(value!),
                                imageUrl: _editedproduct.imageUrl,
                                isFavourite: _editedproduct.isFavourite);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a value';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please enter number greater than zero';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initvalue['description'],
                          decoration: InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          onSaved: (value) {
                            _editedproduct = Product(
                                id: _editedproduct.id,
                                title: _editedproduct.title,
                                description: value as String,
                                price: _editedproduct.price,
                                imageUrl: _editedproduct.imageUrl,
                                isFavourite: _editedproduct.isFavourite);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a value';
                            }
                            if (value.length < 10) {
                              return 'Should be atleast 10 characters long';
                            }
                            return null;
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: _imageUrlcontroller.text.isEmpty
                                  ? Text('Image Url')
                                  : FittedBox(
                                      child: Image.network(
                                      _imageUrlcontroller.text,
                                      fit: BoxFit.cover,
                                    )),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'ImageUrl',
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlcontroller,
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                focusNode: _imagefocus,
                                onFieldSubmitted: (_) {
                                  _formsave();
                                },
                                onSaved: (value) {
                                  _editedproduct = Product(
                                      id: _editedproduct.id,
                                      title: _editedproduct.title,
                                      description: _editedproduct.description,
                                      price: _editedproduct.price,
                                      imageUrl: value as String,
                                      isFavourite: _editedproduct.isFavourite);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter Image Url';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Enter valid address';
                                  }
                                  if (!value.endsWith('png') &&
                                      !value.endsWith('jpg') &&
                                      !value.endsWith('jpeg')) {
                                    return 'Enter valid URL';
                                  }
                                  return null;
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
            ),
    );
  }
}
