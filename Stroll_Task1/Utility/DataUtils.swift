import Foundation

class DataUtils {
    static func decode(_ fileName: String) -> [User] {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            fatalError("Couldn't find \(fileName) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(fileName) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([User].self, from: data)
        } catch {
            fatalError("Couldn't parse \(fileName):\n\(error)")
        }
    }
}
