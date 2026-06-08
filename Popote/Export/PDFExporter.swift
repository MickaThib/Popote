//
//  PDFExporter.swift
//  Popote
//
//  Created by Mickael on 20/03/2026.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import PDFKit

@MainActor
struct PDFExporter {
    
    static func print(view: some View) {
        
        let pageSize = CGSize(width: 842, height: 595) // A4 paysage en points
        let margin: CGFloat = 24
        
        let availableHeight = pageSize.height - margin * 2
        
        /*
         On propose une largeur confortable au planning.
         La hauteur n'est pas imposée : SwiftUI calcule la hauteur réelle nécessaire.
        */
        let renderer = ImageRenderer(
            content: view
                .fixedSize(horizontal: false, vertical: true)
        )
        
        renderer.proposedSize = .init(
            width: pageSize.width - margin * 2,
            height: nil
        )
        
        renderer.scale = 2.0
        
        let data = NSMutableData()
        
        renderer.render { renderedSize, renderContext in
            
            var mediaBox = CGRect(origin: .zero, size: pageSize)
            
            guard let consumer = CGDataConsumer(data: data as CFMutableData),
                  let pdfContext = CGContext(
                    consumer: consumer,
                    mediaBox: &mediaBox,
                    nil
                  )
            else {
                return
            }
            
            pdfContext.beginPDFPage(nil)
            
            let scale = min(1, availableHeight / renderedSize.height)
            
            let scaledWidth = renderedSize.width * scale
            let scaledHeight = renderedSize.height * scale
            
            let x = (pageSize.width - scaledWidth) / 2
            let y = (pageSize.height - scaledHeight) / 2
            
            pdfContext.saveGState()
            
            pdfContext.translateBy(x: x, y: y)
            pdfContext.scaleBy(x: scale, y: scale)
            
            renderContext(pdfContext)
            
            pdfContext.restoreGState()
            
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        guard let pdfDocument = PDFDocument(data: data as Data) else { return }
        
        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        printInfo.orientation = .landscape
        printInfo.paperSize = pageSize
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .fit
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = true
        
        pdfDocument.printOperation(
            for: printInfo,
            scalingMode: .pageScaleToFit,
            autoRotate: true
        )?.run()
    }
}
