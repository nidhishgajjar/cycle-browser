//
//  ParserResult.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-01.
//

import Foundation


// Based on Alfian Losari tutorial

struct ParserResult: Identifiable {
    
    let id = UUID()
    let attributedString: AttributedString
    let isCodeBlock: Bool
    let codeBlockLanguage: String?
    
}
