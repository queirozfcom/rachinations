# this exception should be used to signal that an inconsistent state
# was found, but due to bad initialization, not bad changes in state
class BadConfig < RuntimeError
end