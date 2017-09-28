require 'octokit'
require 'json'


def fetch_pull_requests(condition)
  Octokit.auto_paginate = false
  client = Octokit::Client.new access_token:get_access_token, per_page:"100"
  client.pull_requests(condition.repository, :state => 'closed') + client.pull_requests('opt-tech/v7-apps',:state => 'open')
end

def fetch_commits(condition)
  Octokit.auto_paginate = true
  client = Octokit::Client.new access_token:get_access_token
  Commits.new(client.commits(condition.repository, since:condition.start_time, until:condition.end_time))
end

def initial_setting(argv)
  st = Time.parse(argv[0])
  et = Time.parse(argv[1])
  print_format = argv[2]
  json_data = open("./condition.json") do |io|
    JSON.load(io)
  end
  ltm = json_data["lightningTeam"]
  repos = json_data["repository"]
  return {st:st, et:et, print_format:print_format, ltm:ltm, repos:repos}
end


class Condition
  attr_reader :start_time, :end_time, :repository
  def initialize(con, repo)
    @start_time = con[:st]
    @end_time = con[:et]
    @lightning_team = con[:ltm]
    @repository = repo
  end

  def include_user?(logion_user)
    @lightning_team.include?(logion_user)
  end

  #ある期間に存在するデータなのかを判定する関数
  def between_start_end(target_time)
    target_time ||= Time.mktime(10000000,1,1,00,00,00)
    @start_time < target_time && @end_time > target_time
  end
end

def get_access_token
  raise 'Runtime error. 環境変数にアクセストークンを入れてください' unless ENV['SDC_ACCESS_TOKEN']
  ENV['SDC_ACCESS_TOKEN']
end



class Commits < Array
  def get_commit_data(condition)
    client = Octokit::Client.new access_token:get_access_token
    self
    .select{|c|
      c[:author] != nil &&
      condition.include_user?(c.attrs[:author][:login]) &&
      c.attrs[:commit][:committer][:name] != "GitHub"
    }
    .map{|e|
      commit = client.commit(condition.repository, e.attrs[:sha])
      {
        sha:e.attrs[:sha],
        author:e.attrs[:author][:login],
        created_at:e.attrs[:commit][:author][:date],
        addition:commit[:stats][:additions],
        deletion:commit[:stats][:deletions],
        total:commit[:stats][:total]
      }
    }
  end

  def get_undefined_author_commits
    self.select{ |c| c[:author] == nil }
    .map{ |c| { author: c.attrs[:commit][:author][:name], commit_hash: c[:sha] }}
  end
end

#outputで欲しいもの
class Result
  #attr_reader :open_pull_requests, :closed_pull_requests, :commits
  def initialize(res, error, condition)
    @repository = condition.repository
    @result = res
    @undifined_author_commits = error[:undifined_author_commits]
  end

  def print(kind)
    puts @repository
    case kind
    when "csv"; print_csv
    when "tsv"; print_tsv
    else
      print_formated
    end
  end

  def print_formated
    puts("開いたpullreqの数#{@result[:opend_pr_count]}")
    puts("閉じたpullreqの数#{@result[:closed_pr_count]}")
    puts("コミット数#{@result[:commit_count]}")
    puts("コードの増加量#{@result[:addition_sum]}")
    puts("コードの減少量#{@result[:deletion_sum]}")
    @undifined_author_commits.each{|c| puts "特定できないAuthor: #{c[:author]} hash: #{c[:commit_hash]}" }
  end

  def print_csv
    puts @result.keys.join(",")
    puts @result.values.join(",")
  end

  def print_tsv
    puts @result.keys.join("\t")
    puts @result.values.join("\t")
  end
end
