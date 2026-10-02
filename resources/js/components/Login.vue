<script setup>
import { ref } from 'vue';
import { api, ApiError } from '../api';

const emit = defineEmits(['autenticado']);

const form = ref({ email: '', password: '', lembrar: false });
const erros = ref({});
const erroGeral = ref('');
const enviando = ref(false);

async function entrar() {
    enviando.value = true;
    erros.value = {};
    erroGeral.value = '';

    try {
        const user = await api.post('/login', form.value);

        if (!user?.id) {
            throw new ApiError('Resposta inesperada do servidor ao entrar.', 500);
        }

        emit('autenticado', user);
    } catch (e) {
        if (e instanceof ApiError && e.status === 422) {
            erros.value = e.errors;
        } else {
            erroGeral.value = e.message;
        }
    } finally {
        enviando.value = false;
    }
}
</script>

<template>
    <div class="flex min-h-screen items-center justify-center px-4">
        <div class="w-full max-w-sm rounded-xl border border-borda bg-cartao p-8 text-cartao-texto shadow-sm">
            <h1 class="text-xl font-semibold">Entrar</h1>
            <p class="mt-1 text-sm text-suave">Acesse para gerenciar as pessoas.</p>

            <form class="mt-6 space-y-4" @submit.prevent="entrar">
                <div>
                    <label class="block text-sm font-medium" for="email">E-mail</label>
                    <input
                        id="email"
                        v-model="form.email"
                        type="email"
                        autocomplete="username"
                        class="mt-1 w-full rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
                        placeholder="admin@exemplo.com"
                        required
                    >
                    <p v-if="erros.email" class="mt-1 text-sm text-perigo">{{ erros.email[0] }}</p>
                </div>

                <div>
                    <label class="block text-sm font-medium" for="password">Senha</label>
                    <input
                        id="password"
                        v-model="form.password"
                        type="password"
                        autocomplete="current-password"
                        class="mt-1 w-full rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
                        placeholder="senha123"
                        required
                    >
                    <p v-if="erros.password" class="mt-1 text-sm text-perigo">{{ erros.password[0] }}</p>
                </div>

                <label class="flex items-center gap-2 text-sm text-suave">
                    <input v-model="form.lembrar" type="checkbox" class="rounded border-campo">
                    Manter conectado
                </label>

                <p v-if="erroGeral" class="text-sm text-perigo">{{ erroGeral }}</p>

                <button
                    type="submit"
                    :disabled="enviando"
                    class="w-full rounded-md bg-destaque px-4 py-2 text-destaque-texto transition hover:bg-destaque-hover disabled:opacity-50"
                >
                    {{ enviando ? 'Entrando…' : 'Entrar' }}
                </button>
            </form>
        </div>
    </div>
</template>
