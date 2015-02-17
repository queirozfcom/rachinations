# To be used to signal that a DSL command has not been correctly used.
#   For instance, when required options have been omitted or when an option
#   of a different type than expected has been provided
class BadDSL < RuntimeError
end