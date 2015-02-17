# this exception should be used to signal that an inconsistent state
# was found due to bad initialization, not bad changes in state
class BadConfig < RuntimeError
end