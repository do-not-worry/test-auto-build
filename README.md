# test-auto-build
# 正常来讲,当你有登录Git和Jenkins服务器权限时可以通过服务端钩子触发自动构建流程
# 但这种权限一般分配给运维而不给开发
# 所以自己开发基于客户端push代码前的自动构建
# 基本思路为Git的pre-push钩子及模拟网页请求构建代码

# 每个Jenkins的Crumb不同,自己配置
# 虚拟机时间延迟,所以调整
# pre-push文件为Git钩子,放在项目.git/hooks目录下,并调整分支名和ssh登录信息