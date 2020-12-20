require 'digest'
require 'open-uri'
require 'nokogiri'
require 'diffy'


def get_doc(url)
  doc = Nokogiri::HTML(URI.open(url))

  # Remove scripts
  doc.search('script').each { |e| e.unlink }
  doc.search('style').each  { |e| e.unlink }

  # Clean new lines, tab and spaces
  text = doc.text.split(/([\r\n]+|[\s]{2,})/).reject do |s|
    s.match(/^\s*$/)
  end.join("\n")

  hash  = Digest::MD5.hexdigest text
  lines = text.split(/\n/).count
  chars = text.length

  {
    'text':  text,
    'hash':  hash,
    'lines': lines,
    'chars': chars
  }
end

def doc_exists?(latest, documents)
  documents.map { |d| d[:hash] }.include?(latest[:hash])
end

def doc_diff(previous, latest)
  Diffy::Diff.new(
    previous[:text],
    latest[:text],
    context: 0
  )
end


uri      = URI.parse(ARGV[0].to_s)
interval = (ARGV[1] || 30).to_i

if uri.scheme.nil? or
   uri.host.nil?
  if uri.to_s.empty?
    STDERR.puts "First parameter expected as the URL"
  else
    STDERR.puts "Invalid URL: #{uri.to_s}"
  end
  exit(1)
end


latest    = get_doc(uri.to_s)
documents = []
documents << latest
diff      = nil

STDERR.puts "- Document has #{latest[:lines]} lines and #{latest[:chars]} characters"

loop do
  rand_interval = (rand * interval + (interval / 2)).to_i
  STDERR.puts "- Sleeping #{rand_interval} seconds..."
  sleep rand_interval

  latest = get_doc(uri.to_s)

  if doc_exists?(latest, documents)
    STDERR.puts "- Document has no changes"
    next
  end

  diff      = doc_diff(documents.last, latest)
  documents << latest

  STDERR.puts "- Document has changed:"
  diff.each { |line| STDOUT.puts "\t#{line.chomp}" }
end
