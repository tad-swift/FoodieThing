//
//  Const.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/26/20.
//

import os
import FirebaseFirestore


let log = Logger(subsystem: "com.FoodieThing.jonah", category: "Debug")

let db = Firestore.firestore()

let pref = UserDefaults.standard

var myUser: User!

var tempPost: [String: Any]!

let regularHeaderElementKind = "regular-header-element-kind"
