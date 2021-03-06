########################################################################
# AwsCloudTrail is the +aws_cloudtrail+ terrform resource,
#
# {https://www.terraform.io/docs/providers/aws/r/cloudtrail.html}
########################################################################
class GeoEngineer::Resources::AwsCloudtrail < GeoEngineer::Resource
  validate -> { validate_required_attributes([:name, :s3_bucket_name]) }

  after :initialize, -> { _terraform_id -> { name } }

  def self._fetch_remote_resources(provider)
    cloudtrails = AwsClients.cloudtrail(provider).describe_trails["trail_list"].map(&:to_h)

    cloudtrails.map do |ct|
      ct[:_terraform_id] = ct[:name]
      ct[:_geo_id] = ct[:name]
      ct
    end
  end
end
