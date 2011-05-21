require Dir.pwd + '/app/api/metaweblog/mappers/post_mapper'
require Dir.pwd + '/app/api/metaweblog/mappers/category_mapper'
require Dir.pwd + '/app/api/metaweblog/mappers/comment_mapper'
require Dir.pwd + '/app/api/metaweblog/mappers/tag_mapper'
require Dir.pwd + '/app/api/metaweblog/mappers/blog_mapper'
require Dir.pwd + '/app/api/metaweblog/mappers/user_mapper'

#WARNING - THE CODE IN THE MAPPER CLASSES ARE HORRIBLE!
#UNFORTUNATLY WHEN DEALING WITH NON NAMED POSITIONAL PARAMETERS AND XML YOU WILL END UP WITH SOME CODE SMELL
#SRP - AT LEAST IT DOES NOT BLEED INTO THE MODEL :)
