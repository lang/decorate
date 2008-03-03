= decorate

Homepage:: http://decorate.rubyforge.org/
Project page:: http://rubyforge.org/projects/decorate/
Git repository:: http://repo.or.cz/w/decorate.git

Decorate is written by Stefan Lang, you can contact me directly
(langstefan at gmx dot at), or post on ruby-talk and include
"decorate" in the subject line.

== Description

Python style decorators for Ruby, some common decorators like
private_method are provided out of the box.

Decorators that come with the decorate library:

* Decorate::PrivateMethod
* Decorate::ProtectedMethod
* Decorate::PublicMethod
* Decorate::ModuleMethod
* Decorate::Memoize
* Decorate::BeforeDecorator

== Hygiene issues

Decorate hooks into (aka redefines) Module#method_added and
Object#singleton_method_added via the classic alias/delegate pattern.
If you override these methods in one of your classes that use
decorators, make sure to call +super+, otherwise decorate breaks.

Also, private_method, protected_method, public_method and
module_method are defined as private methods of Module, but only if
the respective files are required.

== License

Decorate is licensed under the same terms as the main Ruby
implementation. See http://www.ruby-lang.org/en/LICENSE.txt.
