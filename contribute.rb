require 'rugged'

repo = Rugged::Repository.init_at(".")
index = Rugged::Index.new

%w(
  README.md
  Gemfile
  contribute.rb
).each do |file|
  oid = repo.write(File.read(file), :blob)
  index.add(path: file, oid: oid, mode: 0100644)
end

commit_time = Time.now - (60 * 60 * 24 * 365)

author = {
  email: "jkassemi@gmail.com",
  name: "James Kassemi",
  time: commit_time
}

options = {
  tree:       index.write_tree(repo),
  author:     author,
  committer:  author,
  message:    "Just feeling like getting to work.",
  parents:    [],
  update_ref: "HEAD"
}

commit = Rugged::Commit.create(repo, options)
data = DATA.read

while true
  break if commit_time > Time.now
  commit_time += rand (60 * 60)

  File.write("README.md", [data, commit_time.to_s].join("\n"))

  oid = repo.write(File.read("README.md"), :blob)
  index.add(path: "README.md", oid: oid, mode: 0100644)

  author[:time] = commit_time
  options[:message] = commit_time.to_s
  options[:parents] = [commit]
  options[:tree] = index.write_tree(repo)
 
  commit = Rugged::Commit.create(repo, options) 
end

__END__

# Contribute

Because it's fun to play with systems.
