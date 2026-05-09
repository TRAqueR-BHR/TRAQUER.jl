include("__prerequisite.jl")

@testset "Test KdfChildKeyCtrl.generateChildKey matches gen_child_pwd.sh" begin
    parent_key = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff"
    ref = Int16(42)
    script_path = "test/Controller/KdfChildKeyCtrl/assets/gen_child_pwd.sh"

    key_format = BinaryEncoding.base64
    base64_script_output = readchomp(`bash $script_path $parent_key $ref $key_format`)
    expected_base64_child_key = match(r"(?m)^Child key:\s*(.+)$", base64_script_output).captures[1]

    @test KdfChildKeyCtrl.generateChildKey(parent_key, ref, key_format) == expected_base64_child_key

    key_format = BinaryEncoding.hex
    hex_script_output = readchomp(`bash $script_path $parent_key $ref $key_format`)
    expected_hex_child_key = match(r"(?m)^Child key:\s*(.+)$", hex_script_output).captures[1]

    @test KdfChildKeyCtrl.generateChildKey(parent_key, ref, key_format) == expected_hex_child_key
end
