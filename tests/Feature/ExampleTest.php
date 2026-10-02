<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A página inicial (que monta o Vue) abre sem erro.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        // Não depende de `npm run build`: o teste é do Laravel, não dos assets.
        $this->withoutVite();

        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
