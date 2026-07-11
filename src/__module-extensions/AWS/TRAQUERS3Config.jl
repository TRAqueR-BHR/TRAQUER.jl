import AWS

struct TRAQUERS3Config <: AWS.AbstractAWSConfig
    endpoint::String
    region::String
    credentials::AWS.AWSCredentials
    max_attempts::Int
end
