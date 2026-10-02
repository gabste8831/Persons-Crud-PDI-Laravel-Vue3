<script setup>
import { onMounted, ref, watch } from 'vue';
import { api } from '../api';
import { formatarDocumento, formatarTelefone } from '../formatters';

const emit = defineEmits(['novo', 'ver', 'editar']);

const pagina = ref({ data: [], current_page: 1, last_page: 1, total: 0 });
const busca = ref('');
const tipo = ref('');
const carregando = ref(false);
const erro = ref('');
const excluindo = ref(null);

async function carregar(page = 1) {
    carregando.value = true;
    erro.value = '';

    const query = new URLSearchParams({ page, busca: busca.value, tipo: tipo.value });

    try {
        pagina.value = await api.get(`/pessoas?${query}`);
    } catch (e) {
        erro.value = e.message;
    } finally {
        carregando.value = false;
    }
}

async function excluir(pessoa) {
    if (!confirm(`Excluir "${pessoa.nome}"? Esta ação não pode ser desfeita.`)) {
        return;
    }

    excluindo.value = pessoa.id;

    try {
        await api.delete(`/pessoas/${pessoa.id}`);
        // Se era o último item da página, volta uma página.
        const destino = pagina.value.data.length === 1 && pagina.value.current_page > 1
            ? pagina.value.current_page - 1
            : pagina.value.current_page;
        await carregar(destino);
    } catch (e) {
        erro.value = e.message;
    } finally {
        excluindo.value = null;
    }
}

// Debounce simples na busca para não disparar um request por tecla.
let timer;
watch([busca, tipo], () => {
    clearTimeout(timer);
    timer = setTimeout(() => carregar(1), 300);
});

onMounted(() => carregar());
defineExpose({ carregar });
</script>

<template>
    <div class="rounded-xl border border-borda bg-cartao text-cartao-texto shadow-sm">
        <div class="flex flex-wrap items-center gap-3 border-b border-borda p-4">
            <input
                v-model="busca"
                placeholder="Buscar por nome, e-mail ou CPF/CNPJ"
                class="min-w-64 flex-1 rounded-md border border-campo px-3 py-2 outline-none focus:border-destaque"
            >
            <select
                v-model="tipo"
                class="rounded-md border border-campo bg-cartao px-3 py-2 outline-none focus:border-destaque"
            >
                <option value="">Todos os tipos</option>
                <option value="fisica">Física</option>
                <option value="juridica">Jurídica</option>
            </select>
            <button
                class="rounded-md bg-destaque px-4 py-2 text-destaque-texto transition hover:bg-destaque-hover"
                @click="emit('novo')"
            >
                Nova pessoa
            </button>
        </div>

        <p v-if="erro" class="border-b border-borda bg-perigo-fundo p-4 text-sm text-perigo">{{ erro }}</p>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-sm">
                <thead class="bg-superficie text-xs uppercase tracking-wide text-suave">
                    <tr>
                        <th class="px-4 py-3">Nome</th>
                        <th class="px-4 py-3">Tipo</th>
                        <th class="px-4 py-3">CPF/CNPJ</th>
                        <th class="px-4 py-3">Telefone</th>
                        <th class="px-4 py-3">E-mail</th>
                        <th class="px-4 py-3 text-right">Ações</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-linha">
                    <tr v-if="carregando">
                        <td colspan="6" class="px-4 py-8 text-center text-suave">Carregando…</td>
                    </tr>
                    <tr v-else-if="!pagina.data.length">
                        <td colspan="6" class="px-4 py-8 text-center text-suave">Nenhuma pessoa encontrada.</td>
                    </tr>
                    <tr v-for="pessoa in pagina.data" v-else :key="pessoa.id" class="hover:bg-superficie">
                        <td class="px-4 py-3 font-medium">
                            <button class="text-left hover:underline" @click="emit('ver', pessoa)">
                                {{ pessoa.nome }}
                            </button>
                        </td>
                        <td class="px-4 py-3">
                            <span
                                class="rounded-full px-2 py-0.5 text-xs"
                                :class="pessoa.tipo === 'juridica'
                                    ? 'bg-juridica-fundo text-juridica'
                                    : 'bg-fisica-fundo text-fisica'"
                            >
                                {{ pessoa.tipo === 'juridica' ? 'Jurídica' : 'Física' }}
                            </span>
                        </td>
                        <td class="px-4 py-3">{{ formatarDocumento(pessoa.cpf) }}</td>
                        <td class="px-4 py-3">{{ formatarTelefone(pessoa.telefone) }}</td>
                        <td class="px-4 py-3">{{ pessoa.email }}</td>
                        <td class="px-4 py-3 text-right whitespace-nowrap">
                            <button
                                class="rounded-md border border-campo px-3 py-1 transition hover:bg-superficie-hover"
                                @click="emit('ver', pessoa)"
                            >
                                Ver
                            </button>
                            <button
                                class="ml-2 rounded-md border border-campo px-3 py-1 transition hover:bg-superficie-hover"
                                @click="emit('editar', pessoa)"
                            >
                                Alterar
                            </button>
                            <button
                                :disabled="excluindo === pessoa.id"
                                class="ml-2 rounded-md border border-perigo-borda px-3 py-1 text-perigo transition hover:bg-perigo-fundo disabled:opacity-50"
                                @click="excluir(pessoa)"
                            >
                                Excluir
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="flex items-center justify-between border-t border-borda p-4 text-sm text-suave">
            <span>{{ pagina.total }} registro(s)</span>
            <div class="flex items-center gap-2">
                <button
                    :disabled="pagina.current_page <= 1"
                    class="rounded-md border border-campo px-3 py-1 disabled:opacity-40"
                    @click="carregar(pagina.current_page - 1)"
                >
                    Anterior
                </button>
                <span>{{ pagina.current_page }} / {{ pagina.last_page }}</span>
                <button
                    :disabled="pagina.current_page >= pagina.last_page"
                    class="rounded-md border border-campo px-3 py-1 disabled:opacity-40"
                    @click="carregar(pagina.current_page + 1)"
                >
                    Próxima
                </button>
            </div>
        </div>
    </div>
</template>
