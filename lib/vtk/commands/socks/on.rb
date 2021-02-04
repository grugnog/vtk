# frozen_string_literal: true

require_relative '../../command'

module Vtk
  module Commands
    class Socks
      # Turns on SOCKS connection to VA network
      class On < Vtk::Command
        attr_reader :input, :output, :port

        def initialize(options)
          @options = options
          @port = options['port'] || '2001'

          super()
        end

        def execute(_input: $stdin, output: $stdout)
          @input = input
          @output = output

          return output.puts '----> Already connected to SOCKS.' if connected?

          ensure_host_authenticity
          connect_to_socks
          ensure_connection
        end

        private

        def connected?
          system "curl --max-time 2 -sL --proxy socks5h://127.0.0.1:#{port} sentry.vfs.va.gov 2> /dev/null | " \
            'grep -q sentry-logo'
        end

        def ensure_host_authenticity
          `ssh -q socks -D #{port} exit | grep -v "This account is currently not available." || true`
        end

        def connect_to_socks
          exit if system "lsof -Pi :#{port} -sTCP:LISTEN -t > /dev/null"

          Process.spawn "nohup ssh -o ServerAliveInterval=60 socks -D #{port} -N > /tmp/ssh_socks.log 2>&1 &"
        end

        def ensure_connection
          output.print '----> Connecting'
          10.times do
            sleep 1
            output.print '.'
            next unless connected?

            return output.puts "\r----> Connected to SOCKS."
          end

          output.puts "\r----> ERROR: Could not connect to SOCKS."
        end
      end
    end
  end
end
