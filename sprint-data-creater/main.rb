require 'octokit'
require 'json'
require './CreateSprintData'
require "time"
require 'optparse'

def main()
  ratelimit           = Octokit.ratelimit
  ratelimit_remaining = Octokit.ratelimit.remaining
  puts "rate limit remaining: #{ratelimit_remaining} / #{ratelimit}"
  puts ""

  #初期設定
  init_con = initial_setting(ARGV)

  results = init_con[:repos].map{ |repo|
    condition = Condition.new(init_con, repo)
    #データを取得
    pull_requests = fetch_pull_requests(condition)
    commits = fetch_commits(condition)

    #取ってきたデータから欲しいものを取り出して格納
    res = {}
    res.store(:opend_pr_count, pull_requests.count { |pulls|
      condition.between_start_end(pulls.attrs[:created_at]) &&
      condition.include_user?(pulls.attrs[:user][:login])
      }
    )
    res.store(:closed_pr_count, pull_requests.count { |pulls|
      condition.between_start_end(pulls.attrs[:closed_at]) &&
      condition.include_user?(pulls.attrs[:user][:login])
      }
    )
    error = {undifined_author_commits:commits.get_undefined_author_commits}
    res.store(:commit_count, commits.get_commit_data(condition).count)
    res.store(:addition_sum, commits.get_commit_data(condition).sum{ |h| h[:addition]})
    res.store(:deletion_sum, commits.get_commit_data(condition).sum{ |h| h[:deletion]})
    Result.new(res, error, condition)
  }
  results.each{|r| r.print(init_con[:print_format])}
end

main()
