import Oniguruma
import Dispatch

/// The dispatch queue used to execute thread unsafe operation like `initialize`  `Regex.init`.
internal let onigQueue = DispatchQueue(label: "SwiftOnig")

/// OnigInt.
public typealias OnigInt = Int32
public typealias OnigULong = UInt
public typealias OnigUInt = UInt32

/// This class has no initializers. Use it to check verion information, copyright information, and to initialize and
/// deconstruct `Oniguruma`.
///
/// Before using any Oniguruma methods,  you'll need to call `Oniguruma.initialize`. This will initialize the library
/// and prepare it for any encodings you provide.
///
/// Additionally, once you've finished using the library call the `Oniguruma.uninitialize` method. This will deconstruct
/// all objects and free any used memory.
/// **You are not allowed to use regex objects created before this call.**
final class Oniguruma {
    /// Get the oniguruma library version string.
    public static func version() -> String {
        return String(cString: onig_version())
    }

    /// Get the oniguruma library copyright string.
    public static func copyright() -> String {
        return String(cString: onig_copyright())
    }

    /// Initialize the library.
    /// - Note: You have to call it explicitly.
    /// - Parameter encodings: Encodings used in the application.
    public static func initialize<S: Sequence>(encodings: S) throws where S.Element == Encoding {
        try onigQueue.sync {
            onig_initialize(nil, 0)
            for encoding in encodings {
                try callOnigFunction {
                    onig_initialize_encoding(encoding.rawValue)
                }
            }
        }
    }

    /// The use of this library is finished.
    /// - Note: It is not allowed to use regex objects which created before `uninitialize` call.
    public static func uninitialize() {
        onigQueue.sync {
            _ = onig_end()
        }
    }
}

/// Call oniguruma functions and throw a typed error.
/// - Parameter body: The closure calling oniguruma library functions
/// - Throws: `OnigError` if `body` returns code not in following normal return codes:
///         [`ONIG_NORMAL`, `ONIG_MISMATCH`, ``ONIG_NO_SUPPORT_CONFIG`, `ONIG_ABORT`]
/// - Returns: The `OnigInt` status code after running the oniguruma methods.
@discardableResult
internal func callOnigFunction(_ body: () throws -> OnigInt) throws -> OnigInt {
    let result = try body()

    switch result {
    case _ where result > 0:
        return result
    case ONIG_NORMAL, ONIG_MISMATCH, ONIG_NO_SUPPORT_CONFIG, ONIG_ABORT:
        return result
    default:
        throw OnigError(onigErrorCode: result)
    }
}
