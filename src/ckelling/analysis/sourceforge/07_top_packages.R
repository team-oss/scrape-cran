#this identifies the top packages by downloads
#first have to go to data and sort it manually and search for Science& Engineering or Statistics


which(cleaned_SF$OSS.Title== "R Portable")
which(cleaned_SF$OSS.Title== "gretl")
which(cleaned_SF$OSS.Title== "Microsoft's TrueType core fonts")

test <- rank(-cleaned_SF$Total.Downloads)

test[113292]
test[which(cleaned_SF$OSS.Title== "Microsoft's TrueType core fonts")]
test[which(cleaned_SF$OSS.Title== "gretl")]
test[which(cleaned_SF$OSS.Title== "R Portable")]
test[which(cleaned_SF$OSS.Title== "Weka")]


cleaned_SF[which(cleaned_SF$OSS.Title== "Weka"),]
