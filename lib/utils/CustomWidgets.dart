import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldLogin extends StatelessWidget {
  CustomTextFieldLogin(
      {this.icon,
      this.icon2,
      this.list,
      this.hint,
      this.obscure,
      this.controller,
      this.obsecure = false,
      this.onChanged,
      this.KeyboardType,
      this.autofillHints,
      this.validator,
      this.textInputAction,
      this.onSaved});
  final FormFieldSetter<String> onSaved;
  final Function onChanged;
  final Icon icon;
  final TextInputType KeyboardType;
  final List<String> autofillHints;
  final List<TextInputFormatter> list;
  final IconData icon2;
  final TextInputAction textInputAction;
  final String hint;
  final Function obscure;
  final bool obsecure;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                hint,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          onChanged: onChanged,
          onSaved: onSaved,
          keyboardType: KeyboardType,
          autofillHints: autofillHints,
          cursorColor: Color(0xff041B9D),
          inputFormatters: list,
          controller: controller,
          validator: validator,
          autofocus: false,
          obscureText: obsecure,
          textInputAction: textInputAction,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
//            prefixIcon: Padding(
//              child: IconTheme(
//                data: IconThemeData(color: Theme.of(context).accentColor),
//                child: icon,
//              ),
//              padding: EdgeInsets.only(left: 30, right: 10),
//            ),
            suffixIcon: Padding(
              child: IconButton(
                  icon: Icon(icon2),
                  color: Color(0xff041B9D),
//              iconSize: 30.0,
                  onPressed: obscure),
              padding: EdgeInsets.only(left: 10, right: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class CustomTextField2 extends StatelessWidget {
  CustomTextField2(
      {this.icon,
      this.icon2,
      this.hint,
      this.obscure,
      this.controller,
      this.obsecure = false,
      this.validator,
      this.onSaved});
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final IconData icon2;
  final String hint;
  final Function obscure;
  final bool obsecure;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                hint,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          onTap: obscure,
          textInputAction: TextInputAction.next,
          enableInteractiveSelection: false, // will disable paste operation
          focusNode: new AlwaysDisabledFocusNode(),
          onSaved: onSaved,
          cursorColor: Theme.of(context).accentColor,
          controller: controller,
          validator: validator,
          autofocus: false,
//            obscureText: obsecure,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
//              prefixIcon: Padding(
//                child: IconTheme(
//                  data: IconThemeData(color: const Color(0xff5956E9)),
//                  child: icon,
//                ),
//                padding: EdgeInsets.only(left: 30, right: 10),
//              ),

            suffixIcon: Padding(
              child: IconButton(
                  icon: Icon(icon2),
                  color: Theme.of(context).accentColor,
//              iconSize: 30.0,
                  onPressed: () {
                    print('tapped');
                  }),
              padding: EdgeInsets.only(left: 0, right: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {this.icon,
      this.icon2,
      this.list,
      this.hint,
      this.obscure,
      this.controller,
      this.obsecure = false,
      this.onChanged,
      this.validator,
      this.textInputAction,
      this.onSaved});
  final FormFieldSetter<String> onSaved;
  final Function onChanged;
  final Icon icon;
  final List<TextInputFormatter> list;
  final IconData icon2;
  final TextInputAction textInputAction;
  final String hint;
  final Function obscure;
  final bool obsecure;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                hint,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          onChanged: onChanged,
          onSaved: onSaved,
          cursorColor: Theme.of(context).accentColor,
          inputFormatters: list,
          controller: controller,
          validator: validator,
          autofocus: false,
          maxLines: 10,
          minLines: 1,
          obscureText: obsecure,
          textInputAction: TextInputAction.newline,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Colors.grey),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
//            prefixIcon: Padding(
//              child: IconTheme(
//                data: IconThemeData(color: Theme.of(context).accentColor),
//                child: icon,
//              ),
//              padding: EdgeInsets.only(left: 30, right: 10),
//            ),
            suffixIcon: Padding(
              child: IconButton(
                  icon: Icon(icon2),
                  color: Theme.of(context).accentColor,
//              iconSize: 30.0,
                  onPressed: obscure),
              padding: EdgeInsets.only(left: 10, right: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextFieldLogin2 extends StatelessWidget {
  CustomTextFieldLogin2(
      {this.icon,
      this.label,
      this.icon2,
      this.list,
      this.hint,
      this.obscure,
      this.controller,
      this.obsecure = false,
      this.onChanged,
      this.autofillHints,
      this.validator,
      this.KeyBoardType,
      this.textInputAction,
      this.onSaved});
  final FormFieldSetter<String> onSaved;
  final Function onChanged;
  final Icon icon;
  final TextInputType KeyBoardType;
  final List<String> autofillHints;
  final List<TextInputFormatter> list;
  final Widget icon2;
  final TextInputAction textInputAction;
  final String hint;
  final String label;
  final Function obscure;
  final bool obsecure;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                hint,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        TextFormField(
          onChanged: onChanged,
          onSaved: onSaved,
          keyboardType: KeyBoardType,
          autofillHints: autofillHints,
          cursorColor: Theme.of(context).accentColor,
          inputFormatters: list,
          controller: controller,
          validator: validator,
          autofocus: false,
          obscureText: obsecure,
          textInputAction: textInputAction,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            hintText: label,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
//                width: 0.001,
              ),
            ),
//            prefixIcon: Padding(
//              child: IconTheme(
//                data: IconThemeData(color: Theme.of(context).accentColor),
//                child: icon,
//              ),
//              padding: EdgeInsets.only(left: 30, right: 10),
//            ),
            suffixIcon: Padding(
              child: icon2,
              padding: EdgeInsets.only(left: 10, right: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class DisplayNameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "*Required";
    }
//    if (value.length < 8) {
//      return "Name is too short";
//    }
    return null;
  }
}

class SearchBox extends StatefulWidget {
  SearchBox({
    Key key,
    this.onChanged,
    this.isLoading,
    this.function,
    this.hintText,
    this.focusNode,
    this.textEditingController,
  }) : super(key: key);

  final ValueChanged onChanged;
  final Function function;
  final String hintText;
  final bool isLoading;
  final FocusNode focusNode;
  final TextEditingController textEditingController;

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final GlobalKey<FormState> _amountFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
//      padding: EdgeInsets.symmetric(
//        horizontal: kDefaultPadding,
//        vertical: kDefaultPadding / 4, // 5 top and bottom
//      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _fuc,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hintText,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff031D39)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.search,
                    color: Color(0xff031D39),
                    size: 24,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  bool amountValidateAndSave() {
    final form = _amountFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _fuc() async {
//    if (amountValidateAndSave()) {
    widget.function();
//    }else{
//      print('no price set');
//    }
  }
}

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;

  MarqueeWidget({
    @required this.child,
    this.direction: Axis.horizontal,
    this.animationDuration: const Duration(milliseconds: 3000),
    this.backDuration: const Duration(milliseconds: 800),
    this.pauseDuration: const Duration(milliseconds: 800),
  });

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController(initialScrollOffset: 50.0);
    WidgetsBinding.instance.addPostFrameCallback(scroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: scrollController,
    );
  }

  void scroll(_) async {
    while (scrollController.hasClients) {
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients)
        await scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: widget.animationDuration,
            curve: Curves.ease);
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients)
        await scrollController.animateTo(0.0,
            duration: widget.backDuration, curve: Curves.easeOut);
    }
  }
}
