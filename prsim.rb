#encoding:gbk
require "pp"

$high_senior = ["�߼������Ա"]
$tag_5 = %w"�ٻ� �س� ���� �����Ա"
$tag_4 = %w"���� ֧Ԯ ���ٸ��� ���� λ��"
$tag_3 = %w"�ѻ� ��ʦ �ȷ� ���� ��װ ҽ�� ���� �� Ů ��սλ Զ��λ ��� ���� ���� ���� ���ûָ� Ⱥ�� ���� ����"

$group_5 = [%w"ҽ�� ֧Ԯ", %w"���� ֧Ԯ", %w"���ûָ� ֧Ԯ", %w"���� ���", %w"��װ ���",
           %w"���� ����", %w"���� ���", %w"Ⱥ�� ����", %w"λ�� ����", %w"λ�� ���", %w"λ�� ����"]
$group_4 = [%w"��ʦ Ů�� ���", %w"���� Ⱥ��", %w"���� Ⱥ��", %w"�ѻ� Ⱥ��", %w"���� Ⱥ��", %w"��սλ Ⱥ��", 
            %w"��սλ ����", %w"���� ����", %w"���� ���",
            %w"��սλ ����", %w"���� ����", %w"��սλ ��", %w"�� ����", %w"�ѻ� ����", %w"Զ��λ ����"]

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
        #   puts "* �س飬��Ϊ������ϡ��tag���: #{x} => #{g}" if b
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
    puts "*** ����5��Tag ***"
    make($tag_3 + $tag_4 + $tag_5, $tag_5)
end

def make_senior
    puts "*** ����6��Tag ***"
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
puts "�����Բ�ģ���� by �޵µ�Ͷʯ��"
puts "����1d1000, <5=���ʣ�<25=����, <200=4�ǣ�����3��"
puts "���Բ⣬����Ϸ��ʵ�����޹أ���������"
puts "---------------------------------------------------"
puts "���س���ʼ,Ctrl-c�˳���ͳ��..."
n = 0
while gets
    n += 1
    roll = rand(1000)
    puts "- ��roll����#{roll}�㣡"
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
        puts "- �ѹ��� #{trial-1} �鳬����ǰϡ�жȵ����" if trial>1
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
    puts "��: #{n}, 3��: #{stats[3]}, 4��: #{stats[4]}, 5��: #{stats[5]}, 6��: #{stats[6]}"
    puts "Tags:"
    pp stats
    puts "���س��˳�..."
    gets
end
