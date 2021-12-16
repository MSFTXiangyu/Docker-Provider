#!/usr/local/bin/ruby
# frozen_string_literal: true

class CustomMetricsUtils
    def initialize
    end

    class << self
        def check_custom_metrics_availability
            aks_region = ENV['AKS_REGION']
            aks_resource_id = ENV['AKS_RESOURCE_ID']
            aks_cloud_environment = ENV['CLOUD_ENVIRONMENT']
            if aks_region.to_s.empty? || aks_resource_id.to_s.empty?
                return false # This will also take care of AKS-Engine Scenario. AKS_REGION/AKS_RESOURCE_ID is not set for AKS-Engine. Only ACS_RESOURCE_NAME is set
            end
            is_ArcA_Cluster = ENV['IS_ARCA_CLUSTER']
            if is_ArcA_Cluster.to_s.downcase == "true" && ENV['ARCA_Metrics_Endpoint']
                return true
            end

            return true
        end
    end
end