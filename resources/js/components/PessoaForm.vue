<script setup>
import { onMounted, ref, watch } from 'vue';
import { api, ApiError } from '../api';
import { digitos, formatarDocumento, formatarTelefone } from '../formatters';

const props = defineProps({
    // null = cadastro; objeto = alteração
    pessoa: { type: Object, default: null },
});

const emit = defineEmits(['salvo', 'cancelar']);

const form = ref({ nome: '', cpf: '', tipo: 'fisica', telefone: '', email: '' });
const erros = ref({});
const erroGeral = ref('');
const salvando = ref(false);

onMounted(() => {
    if (props.pessoa) {
        form.value = {
            nome: props.pessoa.nome,
            cpf: formatarDocumento(props.pessoa.cpf),
            tipo: props.pessoa.tipo,
            telefone: formatarTelefone(props.pessoa.telefone),
            email: props.pessoa.email,
        };
    }
});

// Máscaras aplicadas enquanto o usuário digita.
watch(() => form.value.cpf, (v) => { form.value.cpf = formatarDocumento(v); });
watch(() => form.value.telefone, (v) => { form.value.telefone = formatarTelefone(v); });

// Trocar o tipo muda o tamanho do documento — limpa para não ficar inconsistente.
watch(() => form.value.tipo, () => { form.value.cpf = ''; });

async function salvar() {
    salvando.value = true;
    erros.value = {};
    erroGeral.value = '';

    const dados = {
        ...form.value,
        cpf: digitos(form.value.cpf),
        telefone: digitos(form.value.telefone),
    };

    try {
        const salva = props.pessoa
            ? await api.put(`/pessoas/${props.pessoa.id}`, dados)
            : await api.post('/pessoas', dados);

        emit('salvo', salva);
    } catch (e) {
        if (e instanceof ApiError && e.status === 422) {
            erros.value = e.errors;
        } else {
            erroGeral.value = e.message;
        }
    } finally {
        salvando.value = false;
    }
}
</script>

<template>
    <div class="rounded-xl border border-borda bg-cartao p-6 text-cartao-texto shadow-sm">
        <h2 class="text-lg font-semibold">
            {{ pessoa ? 'Alterar pessoa' : 'Cadastrar pessoa' }}
        </h2>

        <form class="mt-5 grid gap-4 sm:grid-cols-2" @submit.prevent="salvar">
            <div class="sm:col-span-2">
                <label class="block text-sm font-medium" for="nome">Nome</label>
                <input
                    id="nome"
                    v-model="form.nome"
                    class="mt-1 w-full rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
                >
                <p v-if="erros.nome" class="mt-1 text-sm text-perigo">{{ erros.nome[0] }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium" for="tipo">Tipo</label>
                <select
                    id="tipo"
                    v-model="form.tipo"
                    class="mt-1 w-full rounded-md border border-campo bg-cartao px-3 py-2 outline-none focus:border-destaque"
                >
                    <option value="fisica">Pessoa física</option>
                    <option value="juridica">Pessoa jurídica</option>
                </select>
                <p v-if="erros.tipo" class="mt-1 text-sm text-perigo">{{ erros.tipo[0] }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium" for="cpf">
                    {{ form.tipo === 'juridica' ? 'CNPJ' : 'CPF' }}
                </label>
                <input
                    id="cpf"
                    v-model="form.cpf"
                    inputmode="numeric"
                    :placeholder="form.tipo === 'juridica' ? '00.000.000/0000-00' : '000.000.000-00'"
                    class="mt-1 w-full rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
                >
                <p v-if="erros.cpf" class="mt-1 text-sm text-perigo">{{ erros.cpf[0] }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium" for="telefone">Telefone</label>
                <input
                    id="telefone"
                    v-model="form.telefone"
                    inputmode="numeric"
                    placeholder="(00) 00000-0000"
                    class="mt-1 w-full rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
                >
                <p v-if="erros.telefone" class="mt-1 text-sm text-perigo">{{ erros.telefone[0] }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium" for="email-pessoa">E-mail</label>
                <input
                    id="email-pessoa"
                    v-model="form.email"
                    type="email"
                    class="mt-1 w-full rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
                >
                <p v-if="erros.email" class="mt-1 text-sm text-perigo">{{ erros.email[0] }}</p>
            </div>

            <p v-if="erroGeral" class="text-sm text-perigo sm:col-span-2">{{ erroGeral }}</p>

            <div class="flex gap-3 sm:col-span-2">
                <button
                    type="submit"
                    :disabled="salvando"
                    class="rounded-md bg-destaque px-4 py-2 text-destaque-texto transition hover:bg-destaque-hover disabled:opacity-50"
                >
                    {{ salvando ? 'Salvando…' : 'Salvar' }}
                </button>
                <button
                    type="button"
                    class="rounded-md border border-campo px-4 py-2 transition hover:bg-superficie-hover"
                    @click="emit('cancelar')"
                >
                    Cancelar
                </button>
            </div>
        </form>
    </div>
</template>
