require 'json'
require 'node'
require 'mongo'

def store_all current_node, collection
  if current_node.children_nodes == []
    doc = { _id: current_node.fullname, link_id: current_node.parent_id, score: current_node.score, slug: current_node.slug, children_nodes: [] }
    update_or_insert(current_node.fullname, collection, doc)
    return current_node.fullname
  else
    all_children = current_node.children_nodes
    child_id_list = []
    all_children.each do |each_child|
      child_id = store_all(each_child, collection)
      child_id_list << child_id
    end
    doc = { _id: current_node.fullname, link_id: current_node.parent_id, score: current_node.score, slug: current_node.slug, children_nodes: child_id_list }
    update_or_insert(current_node.fullname, collection, doc)
    return current_node.fullname
  end
end

def update_or_insert id, collection, doc
  res = collection.find(_id: id)
  if res.count == 1
    collection.update_one({_id: id}, doc)
  elsif res.count == 0 
    collection.insert_one(doc)
  else
    raise "Found more records than expected"
  end
end

client = Mongo::Client.new('mongodb://127.0.0.1:27017/test')

col_links = client[:links]
col_comments = client[:comments]

tree = RedditTree.new
snapshot = tree.construct_structure
all_links = snapshot.children_nodes

all_links.each do |link|
  doc = { _id: link.fullname, score: link.score, slug: link.slug }
  update_or_insert(link.fullname, col_links, doc)
  comments_for_link = link.children_nodes
  comments_for_link.each do |top_level_comment|
    store_all top_level_comment, col_comments
  end
end
