# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require_relative "../seconds"
require_relative "../statistics"

require "async"
require "async/http/client"
require "async/http/endpoint"

require "samovar"

module Benchmark
	module HTTP
		module Command
			class Latency < Samovar::Command
				self.description = "Determine the optimal level of concurrency."
				
				options do
					option "-k/--concurrency <count>", "The number of simultaneous connections to make.", default: 1, type: Integer
					option "-c/--confidence <factor>", "The confidence required when computing latency (lower is less reliable but faster)", default: 0.99, type: Float
				end
				
				many :hosts, "One or more hosts to benchmark"
				
				def confidence_factor
					1.0 - @options[:confidence]
				end
				
				def measure_performance(concurrency, endpoint, request_path)
					Console.logger.info(self) {"I am running #{concurrency} asynchronous tasks that will each make sequential requests..."}
					
					statistics = Statistics.new(concurrency)
					task = Async::Task.current
					
					concurrency.times.map do
						task.async do
							client = Async::HTTP::Client.new(endpoint, protocol: endpoint.protocol)
							
							statistics.sample(confidence_factor) do
								response = client.get(request_path).tap(&:finish)
							end
							
							client.close
						end
					end.each(&:wait)
					
					Console.logger.info(self, statistics: statistics) do |buffer|
						buffer.puts "I made #{statistics.count} requests in #{Seconds[statistics.sequential_duration]}. The per-request latency was #{Seconds[statistics.latency]}. That's #{statistics.per_second} asynchronous requests/second."
						buffer.puts "\t          Variance: #{Seconds[statistics.variance]}"
						buffer.puts "\tStandard Deviation: #{Seconds[statistics.standard_deviation]}"
						buffer.puts "\t    Standard Error: #{Seconds[statistics.standard_error]}"
					end
					
					return statistics
				end
				
				def run(url)
					endpoint = Async::HTTP::Endpoint.parse(url)
					request_path = endpoint.url.request_uri
					
					Console.logger.info(self) {"I am going to benchmark #{url}..."}
					
					Sync do |task|
						statistics = []
						
						base = measure_performance(@options[:concurrency], endpoint, request_path)
					end
				end
				
				def call
					@hosts.each do |host|
						run(host)
					end
				end
			end
		end
	end
end
