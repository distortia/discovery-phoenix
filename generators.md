# Generators File

Generators used to we can inspect them and maybe tweak them for next time


### Tickets

`mix phoenix.gen.html Ticket tickets title:string body:text resolution:text created_on:datetime assigned_to:references:users company_id:references:companies severity:array:integer created_by:references:users updated_on:datetime tags:array:string status:array:string`

### Users

`mix phoenix.gen.html User users first_name:string last_name:string email:string password:string companies:references:companies`

### Companies

`mix phoenix.gen.html Company companies name:string:unique owner:references:users memebers:references:users`