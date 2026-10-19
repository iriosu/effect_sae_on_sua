import Foundation
import PDFKit
import Vision
import AppKit
let args=CommandLine.arguments
let doc=PDFDocument(url:URL(fileURLWithPath:args[1]))!
var pages:[[String:Any]]=[]
for i in 0..<doc.pageCount {
  let page=doc.page(at:i)!
  let rect=page.bounds(for:.mediaBox)
  let im=page.thumbnail(of:NSSize(width:rect.width*3,height:rect.height*3),for:.mediaBox)
  let req=VNRecognizeTextRequest()
  req.recognitionLevel = .accurate
  req.recognitionLanguages = ["es-ES","en-US"]
  req.usesLanguageCorrection=false
  try VNImageRequestHandler(data:im.tiffRepresentation!,options:[:]).perform([req])
  let lines=req.results!.compactMap { obs -> [String:Any]? in
    guard let t=obs.topCandidates(1).first else{return nil}
    let b=obs.boundingBox
    return ["text":t.string,"confidence":t.confidence,"x":b.minX,"y":b.minY,"width":b.width,"height":b.height]
  }
  pages.append(["page":i+1,"lines":lines])
  fputs("page \(i+1)/\(doc.pageCount)\n",stderr)
}
let data=try JSONSerialization.data(withJSONObject:pages,options:[.prettyPrinted,.sortedKeys])
try data.write(to:URL(fileURLWithPath:args[2]))
