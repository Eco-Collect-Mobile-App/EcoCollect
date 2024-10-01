import 'package:flutter/material.dart';
import 'package:eco_collect/user_management/cocnstants/colors.dart';

const TextStyle descriptionStyle = TextStyle(
  fontSize: 12,
  color: textLight,
  fontWeight: FontWeight.w400,
);

const TextInputDecorarion = InputDecoration(
    hintText: "Email or Username",
    hintStyle: TextStyle(color: textLight, fontSize: 15),
    fillColor: bgBlack,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainYellow, width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        )),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainYellow, width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        )));
