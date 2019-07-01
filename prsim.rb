#encoding:gbk
require "pp"

$high_senior = ["高级资深干员"]
$tag_5 = %w"召唤 控场 爆发 资深干员"
$tag_4 = %w"特种 支援 快速复活 削弱 位移"
$tag_3 = %w"狙击 术师 先锋 近卫 重装 医疗 辅助 男 女 近战位 远程位 输出 防护 生存 治疗 费用恢复 群攻 减速 新手"

$group_5 = [%w"医疗 支援", %w"治疗 支援", %w"费用恢复 支援", %w"防护 输出", %w"重装 输出",
           %w"生存 防护", %w"减速 输出", %w"群攻 削弱", %w"位移 防护", %w"位移 输出", %w"位移 减速"]
$group_4 = [%w"术师 女性 输出", %w"减速 群攻", %w"生存 群攻", %w"狙击 群攻", %w"近卫 群攻", %w"近战位 群攻", 
            %w"近战位 减速", %w"近卫 减速", %w"减速 输出",
            %w"近战位 治疗", %w"防护 治疗", %w"近战位 男", %w"男 防护", %w"狙击 生存", %w"远程位 生存"]

def make(pool, must_pool=[])
    r = pool.sample(6)
    if must_pool.size > 0
        while (r & must_pool).size == 0
            r = pool.sample(6)
        end
    end
    r
end

def no_rare_tag?(x, rare_group=[])
    rare_group.none? {|g|
        g.all? {|tag| x.include?(tag)}.tap {|b|
        #   puts "* 重抽，因为生成了稀有tag组合: #{x} => #{g}" if b
        }
    }
end

def make_3star
    make($tag_3)
end

def make_4star
    make($tag_3 + $tag_4, $tag_4)
end

def make_5star
    puts "*** 生成5星Tag ***"
    make($tag_3 + $tag_4 + $tag_5, $tag_5)
end

def make_senior
    puts "*** 生成6星Tag ***"
    r = $high_senior + ($tag_3 + $tag_4 + $tag_5).sample(5)
    r.shuffle    
    r
end

begin

srand
ret = []
stats = {}
# sort stat
($high_senior + $tag_5 + $tag_4 + $tag_3).each {|t| stats[t] = 0}
puts "---------------------------------------------------"
puts "公招脑测模拟器 by 罗德岛投石兵"
puts "规则：1d1000, <5=高资，<25=资深, <200=4星，其余3星"
puts "纯脑测，与游戏真实机制无关，仅供娱乐"
puts "---------------------------------------------------"
puts "按回车开始,Ctrl-c退出并统计..."
n = 0
while gets
    n += 1
    roll = rand(1000)
    puts "- 你roll到了#{roll}点！"
    if roll < 5
        stats[6] ||= 0
        stats[6] += 1
        ret = make_senior
    elsif roll < 25
        stats[5] ||= 0
        stats[5] += 1
        ret = make_5star
    else
        ok = false
        trial = 0
        tmp = 1
        while not ok
            trial += 1
            if roll < 200
                stats[4] ||= 0; stats[4] += tmp; tmp = 0
                ret = make_4star
                ok = no_rare_tag?(ret, $group_5)
            else
                stats[3] ||= 0; stats[3] += tmp; tmp = 0
                ret = make_3star
                ok = no_rare_tag?(ret, $group_4 + $group_5)
            end
        end
        puts "- 已过滤 #{trial-1} 组超过当前稀有度的组合" if trial>1
    end

    puts "- Tag: #{ret}"
    ret.each {|tag|
        stats[tag] ||= 0
        stats[tag] += 1
    }
    
end

rescue Interrupt
    puts "Interrupted."
    puts "---------------------------------"
    puts "总: #{n}, 3星: #{stats[3]}, 4星: #{stats[4]}, 5星: #{stats[5]}, 6星: #{stats[6]}"
    puts "Tags:"
    pp stats
    puts "按回车退出..."
    gets
end
