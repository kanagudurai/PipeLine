//
//  FootCleaningSession.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-11-29.
//

import Foundation
import Combine

/**
 The `MeshCleaningManager` cleans and settles a mesh asset located at the specified `fileURL`  and saves the cleaned  mesh asset at the specifed `saveURL`. Call the `clean(_,at,saveURL,completion)` to clean a mesh asset. Alternatively, `FootMeshCleaner` can be used to clean a foot mesh.
 */
public class MeshCleaningManager {
    
    /// The default shared manager.
    public static let shared = MeshCleaningManager()
    
    private var subscriptions = Set<AnyCancellable>()
    
    /**
     Returns a Boolean value that indicates whether the `MeshCleaningManager` class can read, clean and export the specified file extension.
     - parameters:
     - fileExtension: The filename extension identifying an asset file format.
     - returns:  `true` if the `MeshCleaningManager` class can read, clean and export asset data from files with the specified extension; otherwise, `false`.
     */
    static func canCleanFileExtension(_ fileExtension: String) -> Bool {
        SupportedFileTypes.isFileExtensionSupported(fileExtension)
    }

    /**
        Cleans and settles the mesh located at the specified `fileURL` and saves the new mesh  at the specifed `saveURL`
     - parameters:
         - meshType: The type of mesh to clean. Only the type `foot` is supported.
         - fileURL: The file URL where to load the orinigal mesh from.
         - saveURL: The file URL where to save the cleaned mesh.
         - completion: The completion handler. If the cleaning and saving is successful, the error is nil.
    - precondition: The `fileURL` and the `saveURL` must have path extensions which `canCleanFileExtension(_)` return `true`.
     */
    public func clean(
        _ meshType: MeshType,
        at fileURL: URL,
        saveURL: URL,
        completion: @escaping (Error?) -> Void
    ) {
        FootMeshCleaner(
            fileURL: fileURL,
            saveURL: saveURL
        )
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure(let cleaningError):
                    completion(cleaningError)
                }
            } receiveValue: {
                completion(nil)
            }
            .store(in: &subscriptions)
    }
}

public extension MeshCleaningManager {
    
    /**
     An enum to represent the type of meshes to expect for the mesh cleaning
     
     - foot: The mesh provided should be a foot. 
     */
    enum MeshType {
        case foot
    }
}

