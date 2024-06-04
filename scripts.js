// Replace these values with your actual contract ABI and address

// const contractABI = /* Your Contract ABI */;
// const contractAddress = "YOUR_CONTRACT_ADDRESS";

// Pinata API credentials
const pinataApiKey = "bd394e3683e7c74cf16a";
const pinataSecretApiKey = "37af6a1e0a79a2e226e9ba1c1cee5ded848aeaba337d85f851840610eac2c22b";

// Initialize Web3
if (window.ethereum) {
    window.web3 = new Web3(window.ethereum);
    window.ethereum.enable();
} else {
    console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
}

document.getElementById('mintForm').addEventListener('submit', async function(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const file = formData.get('file');
    const name = formData.get('name');
    const description = formData.get('description');

    document.getElementById('message').textContent = 'Uploading image to IPFS...';

    try {
        const ipfsHash = await uploadToIPFS(file);
        document.getElementById('message').textContent = 'Minting NFT...';

        const accounts = await web3.eth.getAccounts();
        const contract = new web3.eth.Contract(contractABI, contractAddress);

        await contract.methods.mintNFT(accounts[0], ipfsHash).send({ from: accounts[0] });

        document.getElementById('message').textContent = `NFT Minted! IPFS Hash: ${ipfsHash}`;
    } catch (err) {
        document.getElementById('message').textContent = `Error: ${err.message}`;
    }
});

async function uploadToIPFS(file) {
    const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;
    const data = new FormData();
    data.append('file', file);

    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${pinataApiKey}:${pinataSecretApiKey}`
        },
        body: data
    });

    if (!response.ok) {
        throw new Error('Failed to upload image to IPFS');
    }

    const result = await response.json();
    return result.IpfsHash;
}
