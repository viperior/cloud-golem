puts "Cloud Golem EC2 Instance Start Script Started..."

require 'aws-sdk-ec2'  # v2: require 'aws-sdk'
require_relative 'ec2-credentials.rb'

client = Aws::EC2::Client.new(
  access_key_id: cloud_golem_ec2_access_key_id,
  secret_access_key: cloud_golem_ec2_secret_access_key,
  region: 'us-east-1'
)

ec2 = Aws::EC2::Resource.new(
  client: client
)

i = ec2.instance(cloud_golem_ec2_instance_id)

if i.exists?
  case i.state.code
  when 0  # pending
    puts "#{cloud_golem_ec2_instance_id} is pending, so it will be running in a bit"
  when 16  # started
    puts "#{cloud_golem_ec2_instance_id} is already started"
  when 48  # terminated
    puts "#{cloud_golem_ec2_instance_id} is terminated, so you cannot start it"
  else
    puts "Starting instance with ID #{cloud_golem_ec2_instance_id}. Current state code: #{i.state.code}"
    i.start
    puts "Instance starting..."
  end
end

c = 60

60.times {
  if (c % 10 == 0)
    puts "#{c} seconds elapsed"
  end

  c -= 1
  sleep 1
}

if i.exists?
  case i.state.code
  when 0  # pending
    puts "There was a problem starting instance ID #{cloud_golem_ec2_instance_id}..."
    puts "#{cloud_golem_ec2_instance_id} is still pending"
  when 16  # started
    puts "#{cloud_golem_ec2_instance_id} has been successfully started"
  when 48  # terminated
    puts "There was a problem starting instance ID #{cloud_golem_ec2_instance_id}..."
    puts "#{cloud_golem_ec2_instance_id} is terminated"
  else
    puts "There was an unknown problem (state code: #{i.state.code}) starting instance ID #{cloud_golem_ec2_instance_id}..."
  end
end

puts "Cloud Golem EC2 Instance Start Script Terminated..."
