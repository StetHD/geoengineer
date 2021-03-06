########################################################################
# AwsAlb is the +aws_alb+ terrform resource,
#
# {https://www.terraform.io/docs/providers/aws/r/alb.html Terraform Docs}
########################################################################
class GeoEngineer::Resources::AwsAlb < GeoEngineer::Resource
  validate -> { validate_required_attributes([:subnets]) }
  validate -> { validate_subresource_required_attributes(:access_logs, [:bucket]) }
  validate -> { validate_has_tag(:Name) }

  after :initialize, -> { _terraform_id -> { NullObject.maybe(remote_resource)._terraform_id } }
  after :initialize, -> { _geo_id       -> { NullObject.maybe(tags)[:Name] } }

  def short_type
    "alb"
  end

  def self._merge_attributes(albs, tags)
    albs.map do |alb|
      alb_tags = tags.find { |desc| desc[:resource_arn] == alb[:load_balancer_arn] }
      alb.merge(
        {
          _terraform_id: alb[:load_balancer_arn],
          _geo_id: alb_tags[:tags]&.find { |tag| tag[:key] == "Name" }.dig(:value)
        }
      )
    end
  end

  def self._fetch_remote_resources(provider)
    albs = AwsClients.alb(provider).describe_load_balancers['load_balancers'].map(&:to_h)
    tags = AwsClients.alb(provider)
                     .describe_tags({ resource_arns: albs.map { |alb| alb[:load_balancer_arn] } })
                     .tag_descriptions
                     .map(&:to_h)

    _merge_attributes(albs, tags)
  end
end
