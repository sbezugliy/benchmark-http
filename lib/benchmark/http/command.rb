# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'command/latency'
require_relative 'command/concurrency'
require_relative 'command/spider'
require_relative 'command/hammer'

require_relative 'version'
require 'samovar'
require 'console'

module Benchmark
	module HTTP
		module Command
			def self.call(*args)
				Top.call(*args)
			end
			
			class Top < Samovar::Command
				self.description = "An asynchronous HTTP server benchmark."
				
				options do
					option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
					option '-h/--help', "Print out help information."
					option '-v/--version', "Print out the application version."
				end
				
				nested :command, {
					'latency' => Latency,
					'concurrency' => Concurrency,
					'spider' => Spider,
					'hammer' => Hammer,
				}
				
				def verbose?
					@options[:logging] == :verbose
				end
				
				def quiet?
					@options[:logging] == :quiet
				end
				
				def call
					if verbose?
						Console.logger.debug!
					elsif quiet?
						Console.logger.warn!
					else
						Console.logger.info!
					end
					
					if @options[:version]
						puts "#{self.name} v#{VERSION}"
					elsif @options[:help]
						self.print_usage
					else
						@command.call
					end
				end
			end
		end
	end
end
