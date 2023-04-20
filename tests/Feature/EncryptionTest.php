<?php

namespace Tests\Feature;

use Tests\TestCase;
class EncryptionTest extends TestCase
{
    public function test_ensure_that_the_secret_passwords_file_was_decrypted()
    {
        $pathToSecretFile = __DIR__."/../../passwords.txt";

        $this->assertFileExists($pathToSecretFile);

        $expected = "my_secret_password\n";
        $actual   = file_get_contents($pathToSecretFile);

        $this->assertEquals($expected, $actual);
    }
}
