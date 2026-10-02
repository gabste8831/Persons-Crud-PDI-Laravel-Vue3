<script setup>
import { onMounted, ref } from 'vue';
import { api } from '../api';
import { formatarDocumento, formatarTelefone } from '../formatters';

const props = defineProps({
    pessoa: { type: Object, required: true },
});

const emit = defineEmits(['editar', 'voltar']);

// Começa com o que veio da lista e atualiza com o registro do servidor,
// para não exibir dados velhos se alguém alterou a pessoa nesse meio-tempo.
const dados = ref(props.pessoa);
const erro = ref('');

onMounted(async () => {
    try {
        dados.value = await api.get(`/pessoas/${props.pessoa.id}`);
    } catch (e) {
        erro.value = e.message;
    }
});

const formatarData = (valor) => (valor ? new Date(valor).toLocaleString('pt-BR') : '—');
</script>

<template>
    <div class="rounded-xl border border-gray-200 bg-white p-6 text-gray-900 shadow-sm">
        <h2 class="text-lg font-semibold">{{ dados.nome }}</h2>
        <span
            class="mt-1 inline-block rounded-full px-2 py-0.5 text-xs"
            :class="dados.tipo === 'juridica'
                ? 'bg-indigo-50 text-indigo-700'
                : 'bg-emerald-50 text-emerald-700'"
        >
            {{ dados.tipo === 'juridica' ? 'Pessoa jurídica' : 'Pessoa física' }}
        </span>

        <p v-if="erro" class="mt-4 rounded-md bg-red-50 px-4 py-3 text-sm text-red-700">{{ erro }}</p>

        <dl class="mt-6 grid gap-4 sm:grid-cols-2">
            <div>
                <dt class="text-xs uppercase tracking-wide text-gray-500">
                    {{ dados.tipo === 'juridica' ? 'CNPJ' : 'CPF' }}
                </dt>
                <dd class="mt-1">{{ formatarDocumento(dados.cpf) }}</dd>
            </div>
            <div>
                <dt class="text-xs uppercase tracking-wide text-gray-500">Telefone</dt>
                <dd class="mt-1">{{ formatarTelefone(dados.telefone) }}</dd>
            </div>
            <div class="sm:col-span-2">
                <dt class="text-xs uppercase tracking-wide text-gray-500">E-mail</dt>
                <dd class="mt-1 break-all">{{ dados.email }}</dd>
            </div>
            <div>
                <dt class="text-xs uppercase tracking-wide text-gray-500">Cadastrado em</dt>
                <dd class="mt-1 text-sm text-gray-600">{{ formatarData(dados.created_at) }}</dd>
            </div>
            <div>
                <dt class="text-xs uppercase tracking-wide text-gray-500">Última alteração</dt>
                <dd class="mt-1 text-sm text-gray-600">{{ formatarData(dados.updated_at) }}</dd>
            </div>
        </dl>

        <div class="mt-6 flex gap-3">
            <button
                class="rounded-md bg-gray-900 px-4 py-2 text-white transition hover:bg-gray-700"
                @click="emit('editar', dados)"
            >
                Alterar
            </button>
            <button
                class="rounded-md border border-gray-300 px-4 py-2 transition hover:bg-gray-100"
                @click="emit('voltar')"
            >
                Voltar
            </button>
        </div>
    </div>
</template>
