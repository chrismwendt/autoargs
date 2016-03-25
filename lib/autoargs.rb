require 'autoargs/version'
require 'parser/current'

module Autoargs
    def self.run(method)
        caller_file = caller[0].split(":")[0]

        if caller_file == $0
            ast = Parser::CurrentRuby
                .parse(File.read(caller_file))
                .children
                .select do |node| node.type == :def end
                .map(&:children)
                .select do |name, _| name == method.name end[0]

            abort("No top level method named " + method.name.to_s + " found.") if ast.nil?

            all_args = ast[1].children

            args = all_args
                .select do |arg| arg.type == :arg end
                .map do |arg| arg.children[0] end

            optargs = all_args
                .select do |arg| arg.type == :optarg end
                .map do |arg| { :name => arg.children[0], :default => arg.children[1].children[0] } end

            kwoptargs = Hash[
                all_args
                    .select do |arg| arg.type == :kwoptarg end
                    .map do |arg| [arg.children[0], arg.children[1].children[0]] end
            ]

            usage = [[caller_file],
                args.map do |arg| "<" + arg.to_s + ">" end,
                optargs.map do |optarg| "[" + optarg[:name].to_s + "=" + optarg[:default].inspect + "]" end,
                kwoptargs.map do |name, default| "[--" + name.to_s + " " + default.inspect + "]" end
            ].flatten(1).join(" ")

            argv_args = ARGV[0 ... args.length]
            argv_optargs = ARGV[args.length ... args.length + optargs.length]
            argv_kwoptargs = Hash[
                (ARGV[args.length + optargs.length .. -1] || [])
                    .each_slice(2)
                    .map do |name_with_prefix, value|
                        begin
                            raise "Expected argument " + name_with_prefix + " to start with --." unless name_with_prefix.start_with?("--")
                            raise "Expected value for argument " + name_with_prefix if value.nil?
                            name = name_with_prefix[2 .. -1]
                            raise name + " is not an option." unless kwoptargs.has_key?(name.to_sym)
                            [name.to_sym, value]
                        rescue Exception => e
                            puts(e.message)
                            puts
                            puts(usage)
                            abort
                        end
                    end
            ]

            abort(usage) if argv_args.length < args.length

            positionals = ARGV.slice(0, args.length + optargs.length)
            if argv_kwoptargs.keys.length != 0
                method.call(*positionals, **argv_kwoptargs)
            else
                method.call(*positionals)
            end
        end
    end
end
