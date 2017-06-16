require 'open-uri' 

#is working
a = open("http://mangahost.net/manga/tamen-de-gushi/1").read
a.split(/\n/).each do |as|
	p as
end

#agora que consigo pegar o html novamente, tenho que fazer o programa funcionar novamente