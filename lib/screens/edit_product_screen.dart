import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String appBarTitle = '';
  final _priceFouseNode = FocusNode();
  final _desFouseNode = FocusNode();
  final _imageUlrFouseNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editProduct = Product(
      id: '',
      title: '',
      description: '',
      price: 0.0,
      imageUrl: '',
      isFavorite: false);

  var _isInit = true;
  var _isLoading = false;
  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUlrFouseNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute
          .of(context)!
          .settings
          .arguments as String;

      if (productId != '') {
        appBarTitle = "Edit Product";
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValue = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      } else {
        appBarTitle = "Add Product";
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUlrFouseNode.removeListener(_updateImageUrl);
    FocusScope.of(context).unfocus();
    _priceFouseNode.dispose();
    _desFouseNode.dispose();
    _imageUlrFouseNode.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUlrFouseNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    final _isValidate = _form.currentState!.validate();
    if (!_isValidate) {
      return;
    }
    _form.currentState!.save();

    if (_editProduct.id.isNotEmpty) {
     await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);

    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                title: Text('An error occurred!'),
                content: Text('Something went wrong'),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();

                      },
                      child: Text('OK'))
                ],
              ),
        );
      }
//      finally {
//        setState(() {
//          _isLoading = false;
//        });
//        Navigator.of(context).pop();
//      }
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValue['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFouseNode);
                },
                validator: (value) {
                  if (value
                      .toString()
                      .isEmpty) {
                    return 'Enter Title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editProduct = Product(
                      id: _editProduct.id,
                      isFavorite: _editProduct.isFavorite,
                      title: value!,
                      description: '',
                      price: 0,
                      imageUrl: '');
                },
              ),
              TextFormField(
                initialValue: _initValue['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFouseNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_desFouseNode);
                },
                validator: (value) {
                  if (value
                      .toString()
                      .isEmpty) {
                    return 'Enter price';
                  }

                  if (double.tryParse(value.toString()) == null) {
                    return 'Enter valid amount';
                  }

                  if (double.parse(value.toString()) <= 0) {
                    return 'Enter amount greater than 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editProduct = Product(
                      id: _editProduct.id,
                      isFavorite: _editProduct.isFavorite,
                      title: _editProduct.title,
                      description: '',
                      price: double.parse(value.toString()),
                      imageUrl: '');
                },
              ),
              TextFormField(
                initialValue: _initValue['description'],
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _desFouseNode,
                validator: (value) {
                  if (value
                      .toString()
                      .isEmpty) {
                    return 'Enter Description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editProduct = Product(
                      id: _editProduct.id,
                      isFavorite: _editProduct.isFavorite,
                      title: _editProduct.title,
                      description: value.toString(),
                      price: _editProduct.price,
                      imageUrl: '');
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(
                      top: 8,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      // initialValue: _initValue['imageUrl'],
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUlrFouseNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value) {
                        if (value
                            .toString()
                            .isEmpty) {
                          return 'Enter Image URL';
                        }

                        if (!value.toString().startsWith('http') &&
                            !value.toString().startsWith('https')) {
                          return 'Enter valid Image URL';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            price: _editProduct.price,
                            imageUrl: value.toString());
                      },
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
}
