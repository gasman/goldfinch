module InfixExpression
	def self.tokenize(str)
		str = str.dup # don't clobber the string we were passed
		tokens = []
		until str.empty?
			str.slice!(/^\s+/)
			if token = str.slice!(/^[a-zA-Z]\w*/) # symbol
				tokens << Tokens::Symbol.new(token)
			elsif token = str.slice!(/^\$([0-9a-fA-F]+)/) # hex constant
				tokens << $1.to_i(16)
			elsif token = str.slice!(/^\@([01]+)/) # binary constant
				tokens << $1.to_i(2)
			elsif token = str.slice!(/^\d+/) # decimal constant
				tokens << token.to_i(10)
			elsif token = str.slice!(/^\'(.)\'/) # ascii char
				tokens << $1[0]
			elsif token = str.slice!(/^[\+\-\*\/\%\^\~\|\:]/) # operator
				tokens << Tokens::Operator.new(token)
			elsif token = str.slice!(/^[\(\)]/) # other character
				tokens << token
			else
				raise "syntax error in expression: #{str}"
			end
		end
		tokens
	end
	
	def self.evaluate(str, variables = {})
		tokens = tokenize(str)
		result = consume_tokens(tokens, variables)
		raise "Expected end of expression, got #{tokens.first}" unless tokens.empty?
		result
	end
	
	module Tokens
		class Symbol < String
		end
		class Operator < String
		end
	end
	
	private
	def self.consume_tokens(tokens, variables)
		# first consume an addend: an expression which is more tightly bound than +-~|:
		addend = consume_addend(tokens, variables)
		# we should now find either one of the +-~|: operators, or the end of the (sub)expression
		loop do
			case tokens.first
				when '+'
					tokens.shift
					addend += consume_addend(tokens, variables)
				when '-'
					tokens.shift
					addend -= consume_addend(tokens, variables)
				when '~' # binary AND, apparently...
					tokens.shift
					addend &= consume_addend(tokens, variables)
				when '|' # binary OR
					tokens.shift
					addend |= consume_addend(tokens, variables)
				when ':' # binary XOR apparently
					tokens.shift
					addend ^= consume_addend(tokens, variables)
				else
					# unrecognised token - presumably end of expression or close bracket,
					# but the calling function will worry about that
					break
			end
		end
		
		addend
	end
	
	def self.consume_addend(tokens, variables)
		# first consume a multiplicand: an expression which is more tightly bound than */%
		multiplicand = consume_multiplicand(tokens, variables)
		# we should now find either one of the */% operators, or the end of the sub-expression
		loop do
			case tokens.first
				when '*'
					tokens.shift
					multiplicand *= consume_multiplicand(tokens, variables)
				when '/'
					tokens.shift
					multiplicand /= consume_multiplicand(tokens, variables)
				when '%'
					tokens.shift
					multiplicand %= consume_multiplicand(tokens, variables)
				else
					# unrecognised token - presumably end of sub-expression
					# but the calling function will worry about that
					break
			end
		end
		multiplicand
	end
	
	def self.consume_multiplicand(tokens, variables)
		# first consume an exponent: an expression which is more tightly bound than ^
		exponent = consume_exponent(tokens, variables)
		# we should now find a ^ operator, or the end of the sub-expression
		loop do
			case tokens.first
				when '^'
					tokens.shift
					exponent **= consume_exponent(tokens, variables)
				else
					# unrecognised token, probably end of sub-expression
					break
			end
		end
		exponent
	end
	
	def self.consume_exponent(tokens, variables)
		case tokens.first
			when '('
				# recursively consume the bracketed sub-expression, and hope to find a ) at the end
				tokens.shift
				result = consume_tokens(tokens, variables)
				raise "Expected ), got #{tokens.first || 'end of expression'}" unless tokens.first == ')'
				tokens.shift
				return result
			when '+' # unary plus - no op
				tokens.shift
				return consume_exponent(tokens, variables)
			when '-' # unary minus
				tokens.shift
				return -consume_exponent(tokens, variables)
			when Numeric
				return tokens.shift
			when Tokens::Symbol
				symbol = tokens.shift
				value = variables[symbol] or raise "Unknown symbol: #{symbol}"
				return value
		end
	end

end
