# Use our own CSS
YARD::Templates::Engine.register_template_path File.join(File.dirname(__FILE__), 'templates')

# Force Yard to parse the helpers block in a Middleman extension.
# Because they're not truly instance methods, these are forced into their
# own 'Helpers' group in output.
class HelpersHandler < YARD::Handlers::Ruby::Base
  handles method_call(:helpers)
  namespace_only

  def process
    extra = <<HEREDOC
@note This is not truly an instance method but a **helper** provided by this class.
@group Helpers
HEREDOC

    statement.last.last.each do |node|
      node.docstring.gsub!(/^[\-=]+\n/, '').gsub!(/[\-=]+$/, '') << extra
      parse_block(node, :owner => self.owner)
    end
  end

  def hash_parameters(node)
    hash = {}
    return hash unless node

    param_strings = node.source.split(/,(?=[^\]]*(?:\[|$))/)
    param_strings.each do | param |

      components = param.split(/\=(?=[^\]]*(?:\[|$))/)
                       .each { |c| c.strip! }
      hash[components[0]] = components[1]
    end

    hash
  end
end


# Force Yard to parse the resources.each block in a Middleman extension.
# Because they're not truly instance methods, these are forced into their
# own 'Resource Extensions' group in output.
class ResourcesHandler < YARD::Handlers::Ruby::Base
  handles :def
  namespace_only

  def process
    note = '@note This is not truly an instance method but a **resource method** added to each resource.'
    public = '@visibility public'
    private = '@visibility private'

    if statement.method_name(true).to_sym == :manipulate_resource_list

      statement.docstring = "#{statement.docstring}\n#{private}"
      # Block consists of everything in the actual `do` block
      block = statement.last.first.last.last
      block.each do | node |
        if node.type == :defs
          def_docstring = node.docstring.gsub(/^[\-=]+\n/, '').gsub(/[\-=]+$/, '')
          def_docstring << "#{note}\n#{public}"
          def_name = node[2][0]
          object = YARD::CodeObjects::MethodObject.new(namespace, "resource.#{def_name}")
          register(object)
          object.dynamic = true
          object.source = node.source.clone
          object[:docstring] = def_docstring
          object[:group] = 'Resource Extensions'
        end
      end

    end
  end
end
